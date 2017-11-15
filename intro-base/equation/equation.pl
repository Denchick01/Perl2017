#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;
use Scalar::Util qw(looks_like_number);

if ( @ARGV < 1 || @ARGV > 3 ) {
    die "Bad arguments";
}

my ($a,$b,$c) = @ARGV; 

$b //= 0;
$c //= 0;

if (!looks_like_number($a) || !looks_like_number($b) || !looks_like_number($c)) {
    die "Bad arguments";
}

if ($a == 0) {
     say "Not a quadratic equation";
     exit 0;
}

my ($x1, $x2);

my $dis = $b ** 2 - 4 * $a * $c;

if ($dis < 0) {
    say "No solution!";
    exit 0;
}
elsif ($dis == 0) {
    $x1 = $x2 = -$b / 2 * $a;
}
else {
    $x1 = (-$b + sqrt($b ** 2 - 4 * $a * $c)) / (2 * $a);
    $x2 = (-$b - sqrt($b ** 2 - 4 * $a * $c)) / (2 * $a);
}

say "$x1, $x2";

1;









