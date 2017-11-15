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

my $res;

if ($num == 0) {
    $res = 0;
}
elsif ($num == 1 ) {
    $res = 1;
} 
else {
    for (my $fv = 0, my $sv = 1, my $it = 2; $it <= $num; ++$it) {
        $res = $fv + $sv;        
        $fv = $sv;
	$sv = $res;       	
    }
}

say $res;

1;


