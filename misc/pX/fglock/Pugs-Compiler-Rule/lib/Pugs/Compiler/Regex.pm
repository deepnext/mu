package Pugs::Compiler::Regex;

#use Smart::Comments;

our $VERSION = '0.28';
# Documentation in the __END__
use strict;
use warnings;

use Pugs::Grammar::Rule;
use Pugs::Compiler::RegexPerl5;
use Pugs::Emitter::Rule::Perl5;
use Pugs::Emitter::Rule::Perl5::Ratchet;
use Pugs::Runtime::Regex;
use Pugs::AST::Regex;

# complete the dependency circularity
push @Pugs::Grammar::Rule::ISA, 'Pugs::Grammar::Base';

use Carp qw( croak carp );
use Data::Dumper;
use Symbol 'qualify_to_ref';
use Digest::MD5 'md5_hex';

our $NoCache = $ENV{PCR_NO_CACHE}; # Depresses any caching if set to true

my $cache;
eval {
    require Cache::FileCache;
    $cache = new Cache::FileCache( { 'namespace' => 'v6-rules' } );
};

sub new { $_[0] }

sub compile {
    local $::_V6_MATCH_;  # avoid messing with global $/

    # $class->compile( $source )
    # $class->compile( $source, { p=>1 } )
    # $class->compile( $source, { signature => $sig } ) -- TODO

    my ( $class, $rule_source, $param ) = @_;

    return Pugs::Compiler::RegexPerl5->compile( $rule_source, $param )
        if exists $param->{P5} || exists $param->{Perl5};
    #warn length($rule_source);

    my $self = { source => $rule_source };

    #print Dumper @_;

    # XXX - should use user's lexical pad instead of an explicit grammar?
    $self->{grammar}  = delete $param->{grammar}  ||
                        'Pugs::Grammar::Base';
    $self->{ratchet}  = delete $param->{ratchet}  ||
                        0;

    $self->{p}        = delete $param->{pos}      ||
                        delete $param->{p};
                        # default = undef;
    delete $param->{p};

    $self->{sigspace} = delete $param->{sigspace} ||
                        delete $param->{s}        ||
                        0;
    delete $param->{s};

    $self->{continue} = delete $param->{continue} ||
                        delete $param->{c}        ||
                        0;
    delete $param->{c};

    $self->{ignorecase} = delete $param->{ignorecase} ||
                          delete $param->{i}        ||
                          0;
    delete $param->{i};

    my $error;
    $error .= "Error in rule: unknown parameter '$_'"
        for keys %$param;
    croak $error if %$param;

    my $digest = md5_hex(Dumper($self));
    my $cached;

    if (!$NoCache && $cache && ($cached = $cache->get($digest))) {
        ### using cached rule...
        $self->{perl5} = $cached;
    }
    else {
        ### compiling rule...

        #print 'rule source: ', $self->{source}, "\n";
        #print "match: ", Dumper( Pugs::Grammar::Rule->rule( $self->{source} ) );
        my $ast = Pugs::Grammar::Rule->rule(
            $self->{source} )->();
        if (!defined $ast) {
            carp "Invalid regex syntax";
            return undef;
        }
        ### rule AST: $ast

        Pugs::AST::Regex::optimize($ast)
            if $ENV{PCR_OPTIMIZE};

        # save the ast for debugging
        $self->{ast} = $ast;

        warn Dumper( $ast )
            if $ENV{PCR_DUMP_AST};

        #die "Error in rule: '$rule_source' at: '$ast->tail'\n" if $ast->tail;
        #print 'rule ast: ', do{use Data::Dumper; Dumper($ast{capture})};

        #use Pugs::Emitter::Rule::Perl5::Preprocess;
        #my $ast2 = Pugs::Emitter::Rule::Perl5::Preprocess::emit(
        #         $self->{grammar}, $ast, $self );

        if ( $self->{ratchet} ) {
            $self->{perl5} = Pugs::Emitter::Rule::Perl5::Ratchet::emit(
                 $self->{grammar}, $ast, $self );
            #print "token: ", $self->{perl5};
        }
        else {
            $self->{perl5} = Pugs::Emitter::Rule::Perl5::emit(
                $self->{grammar}, $ast, $self );
        }
        print 'rule perl5: ', do{use Data::Dumper; Dumper($self->{perl5})};

        $cache->set($digest, $self->{perl5}, 'never') if $cache;
    }

    #our $evals++;

    local $@;
    $self->{code} = eval
        # "\#line " . ($evals*1000) . "\n" .
        $self->{perl5};
    die "Error in evaluation: $@\nSource:\n$self->{perl5}\n" if $@;

    #my $code = $self->{code};
    #my $e = $evals;
    #my $c = $self->{perl5};
    #my $x = 1;
    #$c =~ s/\n/"\n".++$x.": "/seg;
    #$self->{code} = sub { print "calling #$e <<< $rule_source >>> compiles to <<< $c >>>\n"; $code->(@_); };

    bless $self, $class;
}

sub code {
    my $rule = shift;
    sub {
        $rule->match( $_[1], $_[0], $_[2], $_[3] );
    }
}

sub match {
    my ( $rule, $str, $grammar, $flags, $state ) = @_;

    #print "match: ",Dumper($rule);
    #print "match: ",Dumper(\@_);
    #print "PCR::match: ",Dumper($_[2]);

    return Pugs::Runtime::Match->new( { bool => \0 } )
        unless defined $str;   # XXX - fix?

    if ( ref $grammar eq 'HASH' ) {
        # backwards compatibility - grammar can now be specified in $flags
        $state = $flags;
        $flags = $grammar;
        $grammar = $flags->{grammar};
    }

    $grammar ||= $rule->{grammar};
    #print "match: grammar $rule->{grammar}, $_[0], $flags\n";
    #print "match: Variables: ", Dumper ( $flags->{args} ) if defined $flags->{args};
    #print "match: Flags: ", Dumper ( $flags ) if defined $flags;

    my $p = defined $flags->{p}
            ? $flags->{p}
            : defined $flags->{pos}
            ? $flags->{pos}
            : $rule->{p};

    my $continue = defined $flags->{c}
            ? $flags->{c}
            : defined $flags->{continue}
            ? $flags->{continue}
            : $rule->{continue};

    my $ignorecase = defined $flags->{i}
            ? $flags->{i}
            : defined $flags->{ignorecase}
            ? $flags->{ignorecase}
            : $rule->{ignorecase};

        #print "flag p";
        #print "match: grammar $rule->{grammar}, $str, %$flags\n";
        #print $rule->{code};

        # XXX BUG! - $rule->{code} disappeared - in t/08-hash.t ???
        unless ( defined $rule->{code} ) {
            local $@;
            if (!defined $rule->{perl5}) {
                croak "Error in evaluation: \$rule->{perl5} is missing";
            }
            $rule->{code} = eval
                $rule->{perl5};
            croak "Error in evaluation: $@\nSource:\n$rule->{perl5}" if $@;
        }

        my %args;
        %args = %{$flags->{args}} if defined $flags && defined $flags->{args};
        $args{p} = $p;
        $args{continue} = $continue;
        $args{ignorecase} = $ignorecase;

        #print "calling code with ",Dumper([ $grammar,$str, $state,\%args ] );
        my $match = $rule->{code}(
            $grammar,
            $_[1], # pass $str itself instead of a copy so as to make pos work
            $state,
            \%args,
        );
        #print __PACKAGE__ . ": match result: ", $match->perl;
        return $match;
}

sub reinstall {
    _install(0, scalar(caller), @_);
}

sub install {
    _install(1, scalar(caller), @_);
}

sub _install {
  my($check, $caller, $class, $name, @etc) = @_;

  # If we have a fully qualified name, use that, otherwise extrapolate.
  my $rule = index($name, '::') > -1 ? $name : $caller."::$name";
  my $slot = qualify_to_ref($rule);

  croak "Can't install regex '$name' as '$rule' which already exists"
    if $check && *$slot{CODE};

  eval {
      no warnings 'redefine';
      *$slot = $class->compile(@etc)->code;
  };
  warn $@ if $@;
}

sub _str { defined $_[0] ? $_[0] : 'undef' }
sub _quot {
    my $s = $_[0];
    $s =~ s/\\/\\\\/sg;
    return $s;
}

sub perl5 {
    my $self = shift;
    return "bless {\n" .
        "  grammar "  .  "=> q(" . _str( $self->{grammar} )  . "),\n" .
        "  ratchet "  .  "=> q(" . _str( $self->{ratchet} )  . "),\n" .
        "  p "        .  "=> " . _str( $self->{p} )        . ",\n" .
        "  sigspace " .  "=> q(" . _str( $self->{sigspace} ) . "),\n" .
        "  ignorecase ". "=> q(" . _str( $self->{ignorecase} )."),\n" .
        "  code "     .  "=> "   . $self->{perl5}    . ",\n" .
        "  perl5 "    .  "=> q(" . _quot( $self->{perl5} )  . "), }, " .
        "q(" . ref($self) . ")";
}

sub perl { perl5(@_) }

1;

__END__

=head1 NAME

Pugs::Compiler::Regex - Compiler for Perl 6 Regex

=head1 SYNOPSIS

    use Pugs::Compiler::Regex;
    use Pugs::Runtime::Match;

    $regex = Pugs::Compiler::Regex->compile('a*b');
    $match = $regex->match('aaab');
    print $match->(), "\n";
    print $match->from, "\n";
    print $match->to, "\n";

    package MyGrammar;
    $regex = Pugs::Compiler::Regex->compile(
        'a*', { ratchet => 1, continue => 1, sigspace => 1 }
    );
    *my_match = $regex->code();
    $match = MyGrammar->my_match('aaaa');
    print "$match\n";

    package MyGrammar2;
    $regex = Pugs::Compiler::Regex->install(
        my_match => 'a*',
        { ratchet => 1, continue => 1, sigspace => 1 }
    );
    $match = MyGrammar->my_match('aaaa');
    print "$match\n";

=head1 DESCRIPTION

This class provides an implementation for Perl 6 regexes.
It serves as a base class for L<Pugs::Compiler::Rule> and
L<Pugs::Compiler::Token>.

=head1 METHODS

=over

=item C<< $regex = Pugs::Compiler::Regex->compile($str, $params); >>

This method acts like a constructor, which returns a
L<Pugs::Compiler::Regex> object from the p6 regex
specified in C<$str>, or throws an exception on
invalid rule syntax.

C<$params> is an optional argument which specifies the
following p6 regex modifiers:

=over

=item C<< grammar => 'Pugs::Grammar::Base' >>

Specify which namespace (Grammar) the rule belongs to.
if C<grammar> is not specified, then C<"Pugs::Grammar::Base"> will
be assumed.

=item C<< continue => 0 >>

=item C<< c => 0 >>

These modifiers cause the pattern to continue
scanning from the string's current C<pos>:

Note that in Perl 6 form

    m:c/pattern/

is roughlh equivalent to

    m:p/ .*? pattern /

Here is an example:

    package Foo;
    Pugs::Compiler::Regex->install(
        word => '\w+',
        { ratchet => 1, continue => 1 }
    );
    $s = 'hello world';
    $match = Foo->word($s); # got 'hello'
    $match = Foo->word($s); # got 'world'

XXX Note that C<continue> or C<c> currently are
not supported in non-ratchet mode.

=item C<< ratchet => 0 >>

Disable backtracking. Much faster. Defaults to 0.
(L<Pugs::Compiler::Rule> and
L<Pugs::Compiler::Token> have the default
value of 1).

=item C<< pos => undef >>

=item C<< p => undef >>

Specify a string position to match. Starts from zero.
Defaults to C<undef>, which matches anywhere in the string.

=item C<< sigspace => 0 >>

Whitespace is significant. Defaults to 0 for
L<Pugs::Compiler::Regex> while 1 for
L<Pugs::Compiler::Rule>.

=item C<< ignorecase => 0 >>

Ignore character case. Defaults to 0 for
L<Pugs::Compiler::Regex>.

=back

=item C<< $regex->perl5() >>

=item C<< $regex->perl() >>

Return a string holding the Perl 5 code for reconstructing
the current L<Pugs::Compiler::Regex> object.

We are trying to make the C<perl5> method does something
like serializing a L<Pugs::Compiler::Regex> instance.

If you want the raw Perl 5 code generated by the
various emitters, use C<< $regex->{perl5} >> directly.

=item C<< $regex->match($str, $grammar, $params) >>

Performs matching action on C<$str>. Note that it's
a thin wrapper around the p5 code compiled from the p6
regex with run-time modifier handling via the C<$params>
argument.

Here is an example:

    $regex = Pugs::Compiler::regex->compile('a*\w');
    my $match = $regex->match('aaa');
    print "Capture: $match";
    print "From: ", $match->from;
    print "To: ", $match->to;

=item C<< $regex->code() >>

Returns a closure (or an anonymous sub) which does the actual
matching task. For example:

  $regex = Pugs::Compiler::Regex->compile('a|b', { ratchet => 1 });
  my $sub = $regex->code();
  my $match = $sub->('MyGrammar', 'aaa');

Or inserts the sub into the current package:

  package Foo;
  $regex = Pugs::Compiler::Regex->compile('a*');
  *match = $regex->code();
  my $match = __PACKAGE__->match('aaa');

Technically it's a thin wrapper around the C<match> method.

=item C<< $regex->install($name, @args_for_compile) >>

Installs the subroutine returned from the C<code> method as
a named subroutine using the name specified by C<$name>;

If C<$name> is fully qualified, then the corresponding
package is used, otherwise the current package is assumed.

C<@args_for_compile> are those arguments fed into the C<compile>
method.

It will croak if there's already a sub with the same name
exists. If that's not what you want, use the C<reinstall>
method instead.

Here are some examples:

  package Bar;
  Pugs::Compiler::Regex->install(match => 'a*', {ratchet => 1});
  $match = Bar->match('aaa');

  # The following line dies with the message
  # "Can't install regex 'match' as 'Bar::match' which already
  # exists":
  Pugs::Compiler::Regex->install(match => 'b*');

=item C<< $regex->reinstall($name, @args_for_compile) >>

Like the C<install> method but it can replaces the named sub
if it already exists:

  package Bar;
  Pugs::Compiler::Regex->install('match', 'a*', {ratchet => 1});
  Pugs::Compiler::Regex->reinstall('match', 'b*');
  };
  $match = Bar->match('bbb'); # matched here

=back

=head1 PACKAGE VARIABLES

=over

=item C<< $Pugs::Compiler::Regex::NoCache >>

By default, the C<compile> method will cache the compiled
form (p5 source) of the p6 regex. The C<NoCache> variable
prevents any caching.

=back

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 Rules Spec: L<http://dev.perl.org/perl6/doc/design/syn/S05.html>

=head1 COPYRIGHT

Copyright 2006 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
