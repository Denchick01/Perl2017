#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;
use Time::Local;

use constant CURRENT_TIME => (localtime time);
use constant MONTH_ARR => qw(January February March April May June 
                           July August September October November December);

if (@ARGV == 1) {
    my $month = shift @ARGV;
	
    !($month < 1 || $month > 12) or die "Invalid month, out of range [1..12]";

    print_cal_for_month($month - 1); 
}
elsif (not scalar @ARGV) {
    print_cal_for_month((CURRENT_TIME)[4]); 
}
else {
    die "Invalid number of parameters"; 
}


sub print_cal_for_month {
    my $month = shift @_;

    say "    ".(MONTH_ARR)[$month]." ".((CURRENT_TIME)[5] + 1900);
    say " Su Mo Tu We Th Fr Sa";

    my @timest = (0, 0, 0, 1, $month, (CURRENT_TIME)[5]); 
    my $first_wday = (localtime timelocal(@timest))[6];

    for (my $it = 0; $it < $first_wday; ++$it) {
        print "   ";
    }

    my $max_day = search_max_mday($month, (CURRENT_TIME)[5]);

    for (my $it = 1; $it <= $max_day; ++$it) {
        $timest[3] = $it;
	my $mday = (localtime timelocal(@timest))[3];
        my $wday = (localtime timelocal(@timest))[6];	    

	printf "%3d", $mday;	
	print "\n" if ($wday == 6);
    }

    print "\n";
}

sub search_max_mday {

    my ($month, $year) = @_;

    if (($month + 1) > 11) {
	 $year += 1;
         $month = 0;
    } else {
         $month += 1;
    }
      
    return (localtime (timelocal(0, 0, 0, 1, $month, $year) - 1))[3];
}


1;
