use v6;
use Test;
plan 59;

# L<S32::Numeric/Num/"=item abs">

=begin pod

Basic tests for the abs() builtin

=end pod

for 0, 0 / 1, 0.0e0, 1, 50, 60.0e0, 99.99 {
    is(abs($_), $_, "got the right absolute value for $_");
#?rakudo skip 'named args'
    is(abs(:x($_)), $_, "got the right absolute value for $_");
    is((abs($_)).WHAT, $_.WHAT, "got the right data type (" ~ $_.WHAT ~ ") of absolute value for $_");
}
for -1, -50, -60.0e0, -9999 / 100 {
    is(abs($_), -$_, "got the right absolute value for $_");
#?rakudo skip 'named args'
    is(abs(:x($_)), -$_, "got the right absolute value for $_");
    is((abs($_)).WHAT, $_.WHAT, "got the right data type (" ~ $_.WHAT ~ ") of absolute value for $_");
}

for 0, 0 / 1, 0.0e0, 1, 50, 60.0e0, 99.99 {
    is(.abs, $_, 'got the right absolute value for $_='~$_);
    is(($_.abs).WHAT, $_.WHAT, 'got the right data type (' ~ $_.WHAT ~ ') of absolute value for $_='~$_);
}
for -1, -50, -60.0e0, -9999 / 100 {
    is(.abs, -$_, 'got the right absolute value for $_='~$_);
    is(($_.abs).WHAT, $_.WHAT, 'got the right data type (' ~ $_.WHAT ~ ') of absolute value for $_='~$_);
}

is( abs(NaN), NaN, 'absolute value of NaN is NaN');
is( abs(Inf), Inf, 'absolute value of Inf is Inf');
is( abs(-Inf), Inf, 'absolute value of -Inf is Inf');

is( abs("-10"), 10, 'absolute value of "-10" is 10');

# vim: ft=perl6
