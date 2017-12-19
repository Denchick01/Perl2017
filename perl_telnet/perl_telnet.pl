use strict;
use warnings;
use 5.10.0;
use AnyEvent;
use Getopt::Long qw(:config no_ignore_case);
use IO::Socket;

$| = 1;

my $host = undef;
my $port = undef;

GetOptions ("<>" => \&take_addr);


if (not defined $host) { 
    die "no host! to connect";
}
elsif (not defined $port) {
    die "no port! to connect"; 
}
elsif ($port !~ m/^\d+$/o) {
    die "The port name is not in the correct format!";
}

my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    Proto    => "tcp",
    Type     => SOCK_STREAM,
) or die "Can't connect to search.cpan.org: $!";


my $cv = AE::cv;

my $sigint; $sigint = AE::signal INT => sub {
    $cv->send; 
};

my @sc_queue;
my @so_queue;

my $stdinr; $stdinr = AE::io \*STDIN, 0, sub { 
    sysread STDIN, my $line, 1024;
    push @sc_queue, $line;

    my $socketw; $socketw = AE::io $socket, 1, sub {
        my $line = shift @sc_queue;
        syswrite $socket, $line or die "write failed: $!";
        undef $socketw;
    };
};

my $socketr; $socketr = AE::io $socket, 0, sub { 
    my $ret = sysread $socket, my $line, 1024;
    if ($ret == 0) {
        say "server is disconected!";
        $cv->send;
    }
    push @so_queue, $line;

    my $stdoutw; $stdoutw = AE::io \*STDOUT, 1, sub {
        my $line = shift @so_queue;
        syswrite STDOUT, $line or die "write failed: $!";
        undef $stdoutw;
    };
};


$cv->recv;

close $socket;

say "telnet stop!";

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
