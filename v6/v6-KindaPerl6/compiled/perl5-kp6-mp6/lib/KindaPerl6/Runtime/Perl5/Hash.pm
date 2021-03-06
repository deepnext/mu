use strict;

=head2 $::Hash

=head3 Parents:

$::Object

=head3 Attributes:

none

=head3 Methods:

=over

=item LOOKUP

=item elems

=item pairs

=item p5landish

You have a Perl 6 string object that you want to compare using `eq`, for
example. The object itself would be a Perl 6 object, and you would use
p5landish on it to get at the actual string contained within it so you can
compare it.

In short, p5landish returns the actual value contained in the object.

See: http://irclog.perlgeek.de/perl6/2007-11-27#i_152004

=back

=cut

$::Hash = KindaPerl6::Runtime::Perl5::MOP::make_class(
    proto   => $::Hash,
    name    => 'Hash',
    parents => [ ],
    methods => {

        new => sub {
            my ( $proto, @param ) = @_;
            my $self = {
                %{$proto},
                _value => { _hash => {} },
            };
            for my $pair ( @param ) {
                ::DISPATCH_VAR( ::DISPATCH( $self, 'LOOKUP', $pair->[0] ), 'STORE', $pair->[1], );
            }
            return $self;
        },
        LOOKUP => sub {
            my $self = shift;
            return $self
                unless @_;
            my $key
                = ref( $_[0] )
                ? ::DISPATCH( ::DISPATCH( $_[0], "Str" ), "p5landish" )
                : $_[0];
            return $self->{_value}{_hash}{$key}
                if exists $self->{_value}{_hash}{$key};
            return ::DISPATCH(
                $::ContainerProxy,
                "new",
                sub {
                        if ( ! exists $self->{_value}{_hash}{$key} ) {
                            $self->{_value}{_hash}{$key} = ::DISPATCH( $::Container, 'new' );
                        }
                        $self->{_value}{_hash}{$key};
                    },
            );
        },
        elems => sub {
            ::DISPATCH( $::Int, "new", scalar( keys( %{ $_[0]{_value}{_hash} } ) ) );
        },
        pairs => sub {
            ::DISPATCH(
                $::List, 'new',
                {   _array => [
                        map { ::DISPATCH( $::Pair, 'new', { key => ::DISPATCH( $::Str, 'new', $_ ), value => $_[0]{_value}{_hash}{$_}, } ) }
                            keys %{ $_[0]{_value}{_hash} }
                    ],
                }
            );
        },
        p5landish => sub { $_[0]{_value}{_hash} }
    }
);


=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

1;
