#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;

if (scalar @ARGV != 2) {
    die "Bad arguments";
}

my ($haystack, $needle) = @ARGV;

my $str_index = index $haystack, $needle;

if ($str_index == -1) {
    warn "Not found";
    exit 0;
}

say $str_index;
say substr $haystack, $str_index;

1;


