{

    package Hash;

    # Do not edit this file - Perl 5 generated by KindaPerl6
    use v5;
    use strict;
    no strict 'vars';
    use KindaPerl6::Runtime::Perl5::Runtime;
    my $_MODIFIED;
    BEGIN { $_MODIFIED = {} }

    BEGIN {
        $_ =
          ::DISPATCH( $::Scalar, "new",
            { modified => $_MODIFIED, name => "$_" } );
    }
    $::Hash =
      ::DISPATCH(
        ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'Hash' ) ),
        'PROTOTYPE', );
    ::DISPATCH(
        ::DISPATCH( $::Hash, 'HOW', ),
        'add_parent',
        ::DISPATCH( $::Str, 'new', 'Container' )
    );
    ::DISPATCH(
        ::DISPATCH( $::Hash, 'HOW', ),
        'add_method',
        ::DISPATCH( $::Str, 'new', 'perl' ),
        ::DISPATCH(
            $::Method,
            'new',
            sub {
                my $self   = shift;
                my $List__ = \@_;
                my $pair;
                $pair =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$pair' } )
                  unless defined $pair;

                BEGIN {
                    $pair =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$pair' } );
                }
                my $s;
                $s =
                  ::DISPATCH( $::Scalar, 'new',
                    { modified => $_MODIFIED, name => '$s' } )
                  unless defined $s;

                BEGIN {
                    $s =
                      ::DISPATCH( $::Scalar, 'new',
                        { modified => $_MODIFIED, name => '$s' } );
                }
                $pair;
                ::DISPATCH_VAR( $s, 'STORE',
                    ::DISPATCH( $::Str, 'new', '{ ' ) );
                do {
                    for my $pair ( ::DISPATCH( $self, 'pairs', ) ) {
                        ::DISPATCH_VAR(
                            $s, 'STORE',
                            ::DISPATCH(
                                $GLOBAL::Code_infix_58__60__126__62_,
                                'APPLY', $s,
                                ::DISPATCH(
                                    $GLOBAL::Code_infix_58__60__126__62_,
                                    'APPLY',
                                    ::DISPATCH( $pair, 'key', ),
                                    ::DISPATCH(
                                        $GLOBAL::Code_infix_58__60__126__62_,
                                        'APPLY',
                                        ::DISPATCH( $::Str, 'new', ' => ' ),
                                        ::DISPATCH(
                                            $GLOBAL::Code_infix_58__60__126__62_,
                                            'APPLY',
                                            ::DISPATCH( $pair, 'value', ),
                                            ::DISPATCH( $::Str, 'new', ', ' )
                                        )
                                    )
                                )
                            )
                        );
                    }
                };
                return (
                    ::DISPATCH(
                        $GLOBAL::Code_infix_58__60__126__62_,
                        'APPLY', $s, ::DISPATCH( $::Str, 'new', ' }' )
                    )
                );
            }
        )
    );
    ::DISPATCH(
        ::DISPATCH( $::Hash, 'HOW', ),
        'add_method',
        ::DISPATCH( $::Str, 'new', 'str' ),
        ::DISPATCH(
            $::Method,
            'new',
            sub {
                my $self   = shift;
                my $List__ = \@_;
                ::DISPATCH( $::Str, 'new', '...' );
            }
        )
    );
    ::DISPATCH(
        ::DISPATCH( $::Hash, 'HOW', ),
        'add_method',
        ::DISPATCH( $::Str, 'new', 'true' ),
        ::DISPATCH(
            $::Method,
            'new',
            sub {
                my $self   = shift;
                my $List__ = \@_;
                ::DISPATCH( $GLOBAL::Code_true, 'APPLY', );
            }
        )
    );
    1
}

