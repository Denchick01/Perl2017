use strict;
use warnings;
use 5.10.0;
use AnyEvent;
use AnyEvent::HTTP;
use AnyEvent::Handle;
use Getopt::Long qw(:config no_ignore_case);
use Web::Query;
use URI;
use AnyEvent::Log;

my @urls_opt            = ();
my $num_of_threads_opt  = 3;
my $recursive_opt       = undef;
my $depth_opt           = 0;
my $relative_opt        = 0;
my $server_response_opt = undef;

use constant TREADS_LIMIT => 50;
use constant MAX_RETRY    => 2;

my $req_count  = 0;
my %checked_links    = (); #link => count счетчик попыток скачать страницу 
my @notchecked_links = (); #[link, depth]

$AnyEvent::HTTP::MAX_PER_HOST = 100;
$AnyEvent::Log::FILTER->level ("info");

GetOptions("N=i" => \$num_of_threads_opt, 
            "r"   => \$recursive_opt , 
            "<>"  => \&take_addr,
            "L"   => \$relative_opt, 
            "l=i" => \$depth_opt,
            "S"   => \$server_response_opt);

die "no valid URL!" if (not scalar @urls_opt);

die "Maximum amount of treads is ".TREADS_LIMIT if ($num_of_threads_opt > TREADS_LIMIT);

push_links([@urls_opt], 0, 0); 

my $cv = AE::cv;

while (makenewreq()) {};

my $w; $w = AnyEvent->idle(
    cb => sub {        
        while (makenewreq()) {};
        stopifneed();
    });

my $ret_prc = $cv->recv // 0;

exit $ret_prc;

sub take_addr {
    if ($_[0] !~ m/^(?:http:\/\/|https:\/\/)/) {
        AE::log error => "Invalide addres $_[0]";
        return;
    }
    push @urls_opt, $_[0];
}

sub push_links {
    my ($links, $depth, $check_retry)  = @_;

    if ($depth > $depth_opt) {
        return;
    }

    for my $link (@{$links}) {
        my $uri = URI->new($link);
        $link = $uri;    
        if (!exists $checked_links{$link}) {
            $checked_links{$link} = 1;
            push @notchecked_links, [$link, $depth];
        }
        elsif ($check_retry && $checked_links{$link} <= MAX_RETRY) {
            $checked_links{$link}++;
            push @notchecked_links, [$link, $depth];
        }
    }
}

sub get_link {
    if (@notchecked_links < 1) {
        return undef;
    }

    return shift @notchecked_links;
}

sub stopifneed {
    if (@notchecked_links < 1 && $req_count  < 1) {
        $cv->send(0);
    }
}

sub makenewreq {

    if ($req_count >= $num_of_threads_opt) {
        return undef;
    }

    my $link = get_link();
    if (not defined $link) {
        return undef;
    }

    ++$req_count;

    my $name  = $link->[0];
    my $depth = $link->[1];

    
    AE::log info => "download: $name";

    http_get (
        "$name", 
        timeout => 5,
            sub {
                my ($body, $hdr) = @_;

                --$req_count;
                if ($hdr->{Status} == 200) {

                    if ($recursive_opt) {
                        my $query = Web::Query->new_from_html($body);
                        my @values =  grep {defined $_ && $_ !~ m/^[#\.]/ && 
                                         ($_ !~ m/^(https?:)?\/\//o || !$relative_opt)} 
                                             $query->find('a')->attr("href");

                        for (@values) {

                            $name =~ m/^(?<MD>(?<SH>https?:\/\/)[\da-z\.-]+\.[a-z\.]{2,6})/o;

                            my $pref = $+{MD};
                            my $shem = $+{SH};

                            if (m/^\/{2}/o) {
                                s/^\/+/$shem/o;
                            }
                            elsif (m/^\//o) {
                                $_ = "$pref$_";
                            }
                            elsif (!m/^https?:\/\//o) {
                                $_ = "$name$_";
                            }
                        }

                        push_links([@values], $depth + 1, 0);
                    }

                    if ($server_response_opt) {
                        my $header = "";
                        while (my ($k, $v) = each %{$hdr}) {
                            $header .= "$k: $v\n";
                        }
                        $body = "$header\n$body";
                    }
 

                    my $filename = "$name.index.html";
                    $filename =~ s/([:\/&\|\?=\.@\s><\$#"'\^*\)\(;`])/"%".ord($1)/eg;
               
                    savepage(\$body, $filename);             
                }                       
                else {
                    AE::log warn => "Fail: Page $name @$hdr{qw(Status Reason)}";
                    push_links([$name], $depth, 1);
                    while (makenewreq()) {};
                    stopifneed();     
                }
             });
return 1;
}

sub savepage {
    my ($body, $filename) = @_;

    my $ret = open my $fd, ">", $filename;

    if (not $ret) {
        warn "Can't open file! $!";
        return;
    }

    my $hdl; $hdl = AE::io $fd, 0, sub {
        my $ret = syswrite $fd, $$body;
        if (not $ret) {
            AE::log error => "write failed: $!";
        }
        close $fd;
        while (makenewreq()) {};
        stopifneed();
        undef $hdl;
    };
}



1;
