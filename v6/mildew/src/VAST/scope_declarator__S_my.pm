use v5.10;
use MooseX::Declare;
class VAST::scope_declarator__S_my {
    use AST::Helpers;
    method emit_m0ld {
        #XXX refactor
        if (my $decl = $self->{scoped}{declarator}) {
            if (my $var_decl = $decl->{variable_declarator}) {
                call(BIND => curlies(varname($var_decl->{variable}))
                    ,[call(new => FETCH(lookup 'Scalar'))]);
            } elsif (my $routine_decl = $decl->{routine_declarator}) {
		$routine_decl->{routine_def}->emit_m0ld('my');
            } else {
                use YAML::XS;
                XXX('unknown scope declarator');
            }
        } elsif (my $multi = $self->{scoped}{multi_declarator}) {
	    $multi->emit_m0ld('my');
        } else {
            XXX('scoped declarator without a declarator');
        }
    }
}