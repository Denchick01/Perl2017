#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;
use Scalar::Util qw(looks_like_number);

if (scalar @ARGV != 1) {
    die "Invalid number of arguments";
}

my $num = shift @ARGV;

if (!looks_like_number($num)) {
    die "$num is not number"
}
elsif ($num < 0 || $num - int $num) {
    die "The number is not natural";
}

my $res = 1;

for (my $it = 1; $it <= $num; ++$it) {
    $res *= $it;
}

say $res;

1;


