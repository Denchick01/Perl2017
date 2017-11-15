#!/usr/bin/env perl

#Для нахождения простых чисел используется алгоритм теста Миллера-Рабина.

use 5.24.1;
use warnings;
use strict;
use bignum;
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


my ($m, $k) = (undef, undef);
my @basis;
my @prime;
	 
for (my $i = 1; $i <= $num; $i++) {	
    my $is_prime = 0;
    $is_prime = 1 if ($i == 2);
    @basis = finde_basis($i);
	
    for my $b (@basis) {
        $is_prime = 1;
        $k = finde_max_power($i, $b);
        $m = ($i - 1)/(2 ** $k);
        my $condition = ($b ** $m) % $i;

        next if ($condition == 1 || $condition == ((-1) % $i));

        $is_prime = 0;
        for (my $n = $k - 1; $n >= 1; $n--) {
            $condition = ($condition ** 2) % $i;
            if ($condition == 1) {
                $is_prime = 0;
                last;
            }

            if ($condition == ((-1) % $i)) {
                $is_prime = 1;
                last;
            }
         }
			last if (!$is_prime);
    }

    push (@prime, $i) if ($is_prime);	
}

say join "\n", @prime;

sub finde_max_power {
    my ($number, $basis) = @_;
    --$number;
    my $k = undef;
    for ($k = 0; !($number % (2 ** ($k + 1))); $k++) {}
    return $k;
}

sub finde_basis {
    my $number = shift;
    my @basis;
    my @range;

    if (!$number) {
        $number = 1;
    }
    for (my $i = 0; $i < 15; $i++) {
       push (@range, int rand($number - 1));
    }
		
    for my $n (@range){
        push (@basis, $n) if ($n % $number);
    }
    return @basis;
}

