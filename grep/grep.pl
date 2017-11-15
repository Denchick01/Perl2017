#!/usr/bin/env perl

use 5.10.0;
use warnings;
use strict;
use Getopt::Long qw(:config no_ignore_case);


my $ignore_case_v = undef;
my $pattern_v = undef;
my $invert_match_v = undef;
my $line_number_v = undef;
my $fixed_strings_v = undef;
my $count_v = undef;
my $after_context_v = 0;
my $before_context_v = 0;
my $context_v = 0;

GetOptions ("i|ignore-case"=> \$ignore_case_v, "v|invert-match" => \$invert_match_v,
            "n|line-number" => \$line_number_v, "F|fixed-strings" => \$fixed_strings_v, 
            "c|count" => \$count_v, "A|after-context=i" =>  \$after_context_v,
            "B|before-context=i" => \$before_context_v, "C|context=i" => \$context_v,
            "<>" => \&take_pattern_v );

if (not defined $pattern_v) {
    die "Need pattern";
}


my $gen_regx = $pattern_v;

if ($fixed_strings_v) {
    $gen_regx = quotemeta($gen_regx);
}

if ($ignore_case_v) {
        $gen_regx = "(?:(?i)".$gen_regx.")";
}

$gen_regx = qr/$gen_regx/;

$after_context_v = $context_v if ($after_context_v < $context_v);
$before_context_v = $context_v if ($before_context_v < $context_v);

my $line_count = 0;
my $get_line = contex_buff($before_context_v);

my $is_gap = -1;
for (my $c_line = $get_line->(), my $a_line_c = 0; defined $c_line->[1]; $c_line = $get_line->()){

    if (!(($c_line->[1] =~ m/$gen_regx/) ^ !$invert_match_v)) {
        if (!$count_v) {
            $a_line_c = $after_context_v;
            $c_line->[1] =~ s/($gen_regx)/\x1b[31m$1\x1b[0m/;
            print "--\n" if ($is_gap > 0 && ($after_context_v || $before_context_v));
            $is_gap = 0;
            print_with_num($_->[1], $_->[0], $line_number_v, "-") for (@{$get_line->(1)});
            print_with_num($c_line->[1], $c_line->[0], $line_number_v, ":");
        }
        else {
            ++$line_count;
        }
    }
    elsif ($a_line_c > 0 && !$count_v) {
        print_with_num($c_line->[1], $c_line->[0], $line_number_v, "-");
        $get_line->(1);
        --$a_line_c;
    }
    else {
        $is_gap = 1 if ($is_gap != -1);
    }
}

say $line_count if ($count_v);


sub print_with_num {
    my ($line, $num, $is_num, $delim) = @_;
    chomp($line);
    print "$num$delim" if ($is_num);
    print $line."\n";
}

sub contex_buff {
    my ($size_bbuff) = @_;
    my @bbuff;
    my $res_line = [0, undef];

    return  sub {

        my $flush_f = shift @_;

        if ($flush_f) {
             my @t_bbuff = @bbuff;
             @bbuff = ();
             $res_line = [0, undef];
             return \@t_bbuff;
        }
        else {
            if (defined $res_line->[1]) {        
                if (@bbuff < $size_bbuff) {
                    push @bbuff, $res_line;
                }
                elsif (@bbuff != 0) {
                    shift @bbuff;
                    push @bbuff, $res_line;
                }
            }
            $res_line = [$., scalar <>];
            return $res_line;
        }
    }
}    

sub take_pattern_v {
    warn "Many patterns" if (defined $pattern_v);
    $pattern_v = shift @_;
}


1;
