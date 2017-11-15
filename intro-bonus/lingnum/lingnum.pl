#!/usr/bin/env perl

use 5.24.1;
use warnings;
use strict;
use Scalar::Util qw(looks_like_number);

use constant NULL_S   => "ноль";
use constant FST_F  => (["", "один", "два"], ["", "одна", "две"]);
use constant FST_S  => ("","", "", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять",
                        "десять", "одиннадцать", "двенадцать", "тринадцать", "четырнадцать","пятнадцать", 
                        "шестнадцать", "семнадцать", "восемнадцать", "девятнадцать");

use constant TENTHS => ("", "десять", "двадцать", "тридцать", "сорок", "пятьдесят", "шестьдесят", "семьдесят", "восемьдесят", "девяносто");
use constant HUNDREDTHS => ("", "сто", "двести", "триста", "четыреста", "пятьсот", "шестьсот", "семьсот", "восемьсот", "девятьсот");

use constant THOUSANDS => (["тысяча", "тысячи", "тысяч", 1], ["миллион", "миллиона", "миллионов", 0], 
                           ["миллиард", "миллиарда", "миллиардов", 0]);



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


say num_to_str($num);


sub num_to_str {
    my $num_v = shift @_;
    my $res;

    if ($num_v == 0) {
        $res = NULL_S;
        return $res;
    }

    my @split_num;

    for (my $th = 1; $th <= $num; $th *= 10) {
        my $c_value = int (($num % ($th * 10)) / $th);
        push @split_num, $c_value;
    }

    $res = make_hundr($split_num[2] // 0, $split_num[1] // 0 , $split_num[0] // 0, 0);

    for (my $it = 3; $it < @split_num; $it += 3) {

       my $temp_res;
       my @temp_arr = ($split_num[$it + 2] // 0, $split_num[$it + 1] // 0 , $split_num[$it] // 0);
       $temp_res = make_hundr(@temp_arr, (THOUSANDS)[$it/3 - 1]->[3])." ";

       my $tens = $temp_arr[1] * 10 + $temp_arr[2]; 
       if (($tens < 10 || $tens > 19) && ($temp_arr[2] == 1)) {
               $res = ${temp_res}.(THOUSANDS)[$it/3 - 1]->[0]." ".${res};
       }
       elsif (($tens < 10 || $tens > 19) && ($temp_arr[2] < 5) && $temp_arr[2] > 1) {
               $res = ${temp_res}.(THOUSANDS)[$it/3 - 1]->[1]." ". ${res};
       }
       else {
               $res = ${temp_res}.(THOUSANDS)[$it/3 - 1]->[2]." ". ${res};
       }
             
    }

    return $res;
}
  

sub make_hundr {
    my ($hun, $ten, $fst, $f_fst) = @_;

    if ($hun > 9 || $ten > 9 || $fst > 9 || $f_fst > 1) {
        die "Inavlide arguments";
    }
    elsif ($hun < 0 || $ten < 0 || $fst < 0 || $f_fst < 0) {
        die "Inavlide arguments";
    }

    my $res_str;
    
    $res_str = (HUNDREDTHS)[$hun];

    my $tens = $ten * 10 + $fst;

    if ($tens < 3) {
        $res_str .= " ".(FST_F)[$f_fst]->[$fst];
    }
    elsif ($tens < 20 && $tens > 2) {
        $res_str .= " ".(FST_S)[$ten * 10 + $fst];
    }
    elsif ($tens >= 20 && $fst < 3) {
        $res_str .= " ".(TENTHS)[$ten]." ".(FST_F)[$f_fst]->[$fst];
    }
    else {
        $res_str .= " ".(TENTHS)[$ten]." ".(FST_S)[$fst];
    }

    return $res_str;
}

1;
