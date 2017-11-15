#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;
use Time::Local;

use constant CURR_UTIME => time;
use constant CURR_TIME => localtime(CURR_UTIME);


my $rem_hour = timelocal(59, 59, (CURR_TIME)[2..5]) - CURR_UTIME + 1;

my $rem_day = (23 - (CURR_TIME)[2]) * 60 * 60 + $rem_hour;

my $rem_wday = (6 - (CURR_TIME)[6]) * 24 * 60 * 60 + $rem_day;

say "$rem_hour $rem_day $rem_wday";

1;






