package Anagram;

use 5.10.0;
use warnings;
use strict;
use Encode qw(encode decode);

sub anagram {
	my $words_list = shift;
	my %result;

        $words_list = [map {$_ = decode('utf8', $_); $_ =~ s/\s//g; lc($_)} @{$words_list}];

        my %group_anagram;

        for my $word (@{$words_list}) {
               my $m_key = join "", sort split "", $word;

               if (!(exists $group_anagram{$m_key})) {
                     $group_anagram{$m_key}[0] = $word;
               }

               $group_anagram{$m_key}[1]{$word} = 1;
        }

        for my $anagrams (values %group_anagram) {
                next if (keys %{$anagrams->[1]} <= 1);
                my $temp = [map {encode('utf8', $_)} sort { $a cmp $b } keys %{$anagrams->[1]}];
                $result{encode('utf8', $anagrams->[0])} = $temp;
        }
        		
	return \%result;
}

1;
