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


die "no host! to connect" if not defined $host;
die "no port! to connect" if not defined $port;

my $addr = gethostbyname $host;
my $sa = sockaddr_in($port, $addr);

if (not $udp_mode_v) {
    socket my $s, AF_INET, SOCK_STREAM, IPPROTO_TCP or die "Can't create socket! $!";

    connect($s, $sa) or die "Can't connect to $host:$port! $!";

    my $msg = join "", <>;

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
    socket my $s, AF_INET, SOCK_DGRAM, IPPROTO_UDP or die "Can't create socket! $!";

    my $msg = join "", <>;

    send($s, $msg, 0, $sa) or die "send: $!";
    
    close $s;
}



sub take_addr {
    my $connect_str = shift @_;
    state $count++;

    $count < 3 or die "More arguments!"; 

    if ($count == 1) {
        $host = $connect_str;
    }
    else {
        $port = $connect_str;
    }
    
}


1;
