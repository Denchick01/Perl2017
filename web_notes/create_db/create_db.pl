#!/usr/bin/env perl
use warnings;
use strict;
use FindBin; 
use utf8;
use open qw(:std :utf8);
use 5.10.0;
use YAML::Tiny;

$| = 1;

my $yaml = YAML::Tiny->read("$FindBin::Bin/../config.yml") or die "Yaml err: $!";

my $db_ct = $yaml->[0]->{plugins}->{DBIC}->{default};

print "Creat DataBase...";

my $ret = system("mysql -u $db_ct->{user} --password=$db_ct->{pass} < tablecreat.sql");

if ($ret) {
    die "Mysql Error: $!";
}

say "ok";

1;
