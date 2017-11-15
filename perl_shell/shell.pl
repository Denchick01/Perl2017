use strict;
use 5.10.0;
use warnings;
use Getopt::Long qw(GetOptionsFromString :config no_ignore_case);
use POSIX ":sys_wait_h";

$| = 1;

my %SHELL_ENV = (
                HOME  => $ENV{HOME},
                PWD   => $ENV{PWD},
                PS1   => "",
                "?" => 0
                );


my @SHELL_CMD = (
                 [qr/^(?<LARG>.+?)\s*\|\s*(?<RARG>.+)$/o, \&shell_pipe, "lr"],
                 [qr/^cd(\s+(?<RARG>.*))?$/o, \&shell_cd, "r"],
                 [qr/^pwd(\s+(?<RARG>.*))?$/o, \&shell_pwd, "r"],
                 [qr/^echo(\s+(?<RARG>.*))?$/o, \&shell_echo, "r"],
                 [qr/^kill(\s+(?<RARG>.*))?$/o, \&shell_kill, "r"],
                 [qr/^ps(\s+(?<RARG>.*))?$/o, \&shell_ps, "r"],
                 [qr/^exec(\s+(?<RARG>.*))?$/o, \&shell_exec, "r"],
                 [qr/^(?<LARG>.+?)(\s+(?<RARG>.*))?$/o, \&shell_program, "lr"]
                );

my $to_kid;

while (1) {

    $SHELL_ENV{"PS1"} = "$SHELL_ENV{PWD}\$";
    	 
    print $SHELL_ENV{"PS1"};
    my $line = <>;	
    next if ($line =~ m/^\s+$/o);

    my ($cmd_func, $args) = parse_cmd($line);

    $SHELL_ENV{"?"} = $cmd_func->($args);
}

sub parse_cmd {
    my $cmd = shift @_;
    chomp $cmd;
 
    my $cmd_func;
    my $cmd_args;
    my $is_find = 0;

    for my $cmd_met (@SHELL_CMD) {
        if ($cmd =~ $cmd_met->[0]) {
            $is_find = 1;
            $cmd_func = $cmd_met->[1];
            if ($cmd_met->[2] eq "l") {
                $cmd_args = [$+{LARG} // ""];
            }
            elsif ($cmd_met->[2] eq "r") {
                $cmd_args = [$+{RARG} // ""];
            }
            else {
                $cmd_args = [$+{LARG} // "", $+{RARG} // ""];
            }
            last;
        }
    }

    if (not $is_find) {
        $cmd_func = \&error_cmd;
        $cmd_args = ["command '$cmd' is not found", 2];
    }

    return $cmd_func, $cmd_args;
}


sub error_cmd {
    my $args = shift @_;
    print STDERR "Error: ", $args->[0], "\n";
    return $args->[1];
}

sub shell_echo {
    my $args = shift @_;
    my $str = $args->[0];

    say get_str($str);
    return 0;
}

sub get_str {
    my $str = shift @_;
    my $res_str = "";

    while ($str =~ /(?<PREF>.*?)(?<MID>(?<QUT>["'])(?<STR>.*?)\g{-2})?/gc) {
        $res_str .= join " ", split qr/\s+/, $+{PREF};
        next if (not $+{MID});

        if ($+{QUT} eq '"') {
            my $temp_str = $+{STR};

            $temp_str =~ s/\$(\S+)/exists($SHELL_ENV{"$1"}) ? $SHELL_ENV{"$1"}: ""/e;
            $res_str .= $temp_str;
        }
        else {
            $res_str .= $+{STR};
        }    
    }

    return $res_str;
}

sub shell_cd {
    my $args = shift @_;
    my $str = $args->[0];

    if (length $str == 0 || $str =~ m/^\s+$/) {
        $str = $SHELL_ENV{HOME}; 
    }

    $str = get_str($str);

    $str .= "/";
    $str =~ s/\/+/\//o;

    my $ret = chdir $str;

    if (not $ret) {
        return error_cmd ["cd: $!", 2];
    }

    if ($str =~ m/^\/.*/) {
        $SHELL_ENV{PWD} = $str;
    }
    else {
        $SHELL_ENV{PWD} .= $str;
    }

    return 0;
}

sub shell_pwd {
    my $args = shift @_;

    say $SHELL_ENV{PWD};

    return 0; 
}

sub shell_kill {
    my $args = shift @_;
    my @pids;
    my $sig = 15;

    if (not length $args->[0]) {
        return error_cmd ["kill: enter options", 2];
    }

    my $ret = GetOptionsFromString($args->[0], "s|signal=i" => \$sig,
                                   "<>" => sub {push @pids, $_[0]});

    if (not $ret) {
         return $ret;
    }

    if (!@pids) {
        return error_cmd ["kill: enter pid", 2];
    }
    elsif (my @badpids = grep { $_ !~ m/^\d+$/} @pids) {
        return error_cmd ["kill: pid can only be a number", 2];
    }

    $ret = kill "-$sig", @pids;

    if (not $ret) {
        return error_cmd ["kill: $!", 2];
    }

    return 0;
}

sub shell_exec {
    my $args = shift @_;

    exec "$args->[0]" or return error_cmd ["command '$args->[0]' is not found", 2]; 
    
}

sub shell_program {
    my $args = shift @_;

    my $pid = fork;

    if ($pid < 0) {
        return error_cmd ["shell: cannot fork", 2];
    }
    elsif (not $pid) {
        exit shell_exec ["$args->[0] $args->[1]"];
    }
    else {
        waitpid $pid, 0;
        return $? >> 8;
    }

    return 0;
}

sub shell_pipe {
    my $args = shift @_;
    my $pid = fork;

    if ($pid < 0) {
        return error_cmd ["shell: cannot fork", 2];
    }
    elsif (not $pid) {
 
        my $r;
        my $w;

        pipe $r, $w or die "can't pipe $1";
        my $ch_pid = fork;

        if ($ch_pid < 0) {
            exit error_cmd ["shell: cannot fork", 2];
        }
        elsif (not $ch_pid) {
            close $w;
            my $rd = fileno $r;
            open STDIN , "<&$rd" or die "Couldn't dup2 $!";
            my ($cmd_func, $cmd_args) = parse_cmd($args->[1]); 
            my $ret = $cmd_func->($cmd_args);
            close $r;
            close STDIN;
            exit $ret;
        }
        else {
            close $r;
            my $wd = fileno $w;
            open STDOUT, ">&$wd" or die "Couldn't dup2 $!";
            my ($cmd_func, $cmd_args) = parse_cmd($args->[0]);            
            $cmd_func->($cmd_args);
            close $w;
            close STDOUT;
            waitpid $ch_pid, 0;
            exit $? >> 8;
        }
    }
    else {
        waitpid $pid, 0;
        return $? >> 8;
    }

    return 0;
}

sub shell_ps {
    my $args = shift @_;
    my $proc_dir = "/proc";
    
    opendir my $dh, "$proc_dir" or return error_cmd ["ps: Can't opendir $proc_dir: $!", 2];

    while (my $file_name = readdir $dh) {
        my $p_dir = "$proc_dir/$file_name";
        next unless (-d $p_dir && $file_name =~ m/^\d+$/o);
        my $f_cmd_line = "$p_dir/comm";  
        my $f_stat = "$p_dir/status";

        open my $fd, "<", "$f_cmd_line" or return error_cmd ["ps: Can't open file $f_cmd_line: $!", 2];
        
        my $cmd_name = <$fd>;
        chomp $cmd_name;
        close $fd;

        open $fd, "<", "$f_stat" or return error_cmd ["ps: Can't open file $f_stat: $!", 2];

        my $proc_pid;
        my $proc_ppid;
        for (<$fd>) {
            if (m/^Pid:\s+(\d+)/o) {
                $proc_pid = $1;
            }
            elsif (m/^PPid:\s+(\d+)/o) {
                $proc_ppid = $1;
            }
        }
        close $fd;
        
        print "$proc_pid  $proc_ppid $cmd_name\n";
    }

    close $dh;
    return 0; 
}


1;


