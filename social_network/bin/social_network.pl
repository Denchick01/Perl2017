#!/usr/bin/env perl

use strict;
use warnings;
use 5.10.0;
use YAML::Tiny;
use FindBin; 
use lib "$FindBin::Bin/../lib";
use Local::Schema;
use JSON::XS;
use utf8;
use Cache::Memcached;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;

my @users;
my $friends_opt        = undef;
my $nofriends_opt      = undef;
my $num_handshakes_opt = undef;


GetOptions ("user=i" => \@users,'<>' => \&process_opt); 

if ($nofriends_opt && @users > 0) {
    pod2usage("Error: invalid query: try: nofriends without option --user");
}
elsif ($friends_opt && @users != 2) {
    pod2usage("Error: invalid query: try: friends --user XX --user YY");
}
elsif ($num_handshakes_opt && @users != 2) {
    pod2usage("Error: invalid query: try: num_handshakes --user XX --user YY");
}
  
my $yaml = YAML::Tiny->read( 'config.yml' );


my $cache = Cache::Memcached->new(servers => [$yaml->[0]->{mch_address}]);

my $schema =  Local::Schema->connect($yaml->[0]->{dsn}, 
                                     $yaml->[0]->{user}, 
                                     $yaml->[0]->{password},
                                     {mysql_enable_utf8 => 1});

#$schema->storage->debug(1);

my $rs = $schema->resultset('User');


my $json_xs = JSON::XS->new->utf8();


if ($friends_opt) {
    say $json_xs->pretty(1)->encode($rs->find($users[0])->search_mutual_friends($users[1], $rs));
}
elsif ($nofriends_opt) {
    say $json_xs->pretty(1)->encode($rs->search_nofriends()->all_to_hash());
}
elsif ($num_handshakes_opt) {
    my $temp_res;
    if ($temp_res = $cache->get($users[0]."_".$users[1])) {
        say $temp_res;
    }
    else {
        $temp_res = $rs->search_num_handshakes($users[0], $users[1]);    
        $cache->set($users[0]."_".$users[1], $temp_res, 120);
        say $temp_res;
    }
}
else {
    die "You did not specify options\n";
}

sub process_opt {
    my ($opt_name) = @_;
    state $opt_num++;
   
    if ($opt_num > 1) {
        pod2usage("Too many options!");
    }
 
    if ($opt_name eq "friends") {
        $friends_opt = 1;
    }
    elsif ($opt_name eq "nofriends") {
        $nofriends_opt  = 1;
    }
    elsif ($opt_name eq "num_handshakes") {
        $num_handshakes_opt = 1;
    }
    else {
        pod2usage("Invalid option $opt_name");
    } 
}

1;

