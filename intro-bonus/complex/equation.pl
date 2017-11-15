#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;
use Math::Complex;

my ($a,$b,$c) = @ARGV;

if (not defined $a) {
    die "Bad arguments";
}
elsif ($a == 0) {
     say "Not a quadratic equation";
     exit 0;
}

$b //= 0;
$c //= 0;

my ($x1, $x2);

my $dis = $b ** 2 - 4 * $a * $c;

if ($dis == 0) {
    $x1 = $x2 = -$b / 2 * $a;
}
else {
    $x1 = (-$b + sqrt($b ** 2 - 4 * $a * $c)) / (2 * $a);
    $x2 = (-$b - sqrt($b ** 2 - 4 * $a * $c)) / (2 * $a);
}

say "$x1, $x2";

1;









