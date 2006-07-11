
package Pugs::Runtime::Common;

use strict;
use warnings;

sub mangle_ident {
    my $s = shift;
    $s =~ s/ ([^a-zA-Z0-9_:]) / '_'.ord($1).'_' /xge;
    return $s;
}

sub mangle_var {
    my $s = $_[0];
    #warn "mangle: $s";
    
    # perl6 => perl5 variables
    return '%::ENV'    if $s eq '%*ENV';  
    return '$^O'       if $s eq '$*OS';  
    
    # special variables
    return '$::_V6ERR_'   if $s eq '$!';
    return '$::_V6MATCH_' if $s eq '$/';

    substr($s,1) =~ s/ ([^a-zA-Z0-9_:]) / '_'.ord($1).'_' /xge;
    return $s;
}

1;
