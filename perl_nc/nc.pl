use strict;
use 5.10.0;
use warnings;
use Getopt::Long qw(:config no_ignore_case);
use Socket ':all';

my $udp_mode_v = undef;
my $host = undef;
my $port = undef;

GetOptions ("u"=> \$udp_mode_v,
            "<>" => \&take_addr);


my $msg = join "", <>;

my $addr = gethostbyname $host;
my $sa = sockaddr_in($port, $addr);

if (not $udp_mode_v) {
    socket my $s, AF_INET, SOCK_STREAM, IPPROTO_TCP;

    connect($s, $sa);
    syswrite $s, $msg or die "write failed: $!";

    while (1) {
        my $r = sysread $s, my $buf, 1024;
        if ($r) { 
            print $buf; 
        }
        elsif (defined $r) { 
            last; 
        } 
        else { 
            die "read failed: $!" 
        }
    } 

    close $s;
}
else {
    socket my $s, AF_INET, SOCK_DGRAM, IPPROTO_UDP;

    send($s, $msg, 0, $sa) or die "send: $!";

    close $s;
}



sub take_addr {
    my $addr = shift @_;
    state $count++;

    $count < 3 or die "More arguments!"; 

    if ($count == 1) {
        $host = $addr;
    }
    else {
        $port = $addr;
    }
    
}


1;
