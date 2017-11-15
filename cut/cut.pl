use 5.10.0;
use warnings;
use strict;
use Getopt::Long;


my $delimiter_v = "\t";
my $only_delimited_v = undef;
my @fields_v;


GetOptions ("f|fields=s"=> \&parse_fields, "d|delimiter=s" => \&parse_delimiter,
            "s|only-delimited" => \$only_delimited_v);

for my $c_line (<>) { 
    chomp($c_line);

    my @c_fields = split /$delimiter_v/, $c_line;

    if ($only_delimited_v && (@c_fields < 2)) {
        next;
    }

    for (@fields_v) {
        my $field_v = $_ - 1;
        if ($field_v >= @c_fields) {
           last;
        }
        print $c_fields[$field_v]." ";        
    }
    print "\n";
}


sub parse_delimiter {
    my $delimiter = $_[1];
 
    if (length $delimiter != 1) { 
        print "Delimiter can be only from one character!\n";
        exit(2);
    }

    $delimiter_v = quotemeta($delimiter);
}

sub parse_fields {
    my $fields_str = $_[1];
  
    @fields_v = sort {$a <=> $b} grep {$_ =~ /^\d+$/ && $_ > 0 or die "Invalide field '$_'"} split ",",  $fields_str;
}


1;
