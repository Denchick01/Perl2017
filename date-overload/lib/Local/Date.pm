package Local::Date;
use POSIX qw(strftime locale_h);
use Mouse;
use Mouse::Util::TypeConstraints;
use Time::Local;
use Scalar::Util qw(looks_like_number);
use Local::Date::Interval;
use 5.10.0;

setlocale(LC_ALL, "en_US");

use overload 
    '0+' => 'data_num_format',
    '""' => 'data_str_format',
    '+'  => 'data_add',
    '-'  => 'data_sub',
    '+=' => 'data_add_s',
    '-=' => 'data_sub_s',
    'fallback' => 1;


subtype 'DayType'
    => as 'Int'
    => where {$_ >= 1 && $_ <= 31}
    => message {"Wrong format for DayType: $_"};

subtype 'MonthType'
    => as 'Int'
    => where {$_ >= 1 && $_ <= 12}
    => message {"Wrong format for MonthType: $_"};

subtype 'YearType'
    => as 'Int'
    => where {$_ >= 1970}
    => message {"Wrong format for YearType: $_"};

subtype 'HoursType'
    => as 'Int'
    => where {$_ >= 0 && $_ <= 23}
    => message {"Wrong format for HoursType: $_"};

subtype 'MinutesType'
    => as 'Int'
    => where {$_ >= 0 && $_ <= 59}
    => message {"Wrong format for MinutesType: $_"};

subtype 'SecondsType'
    => as 'Int'
    => where {$_ >= 0 && $_ <= 59}
    => message {"Wrong format for SecondsType: $_"};

subtype 'EpochType'
    => as 'Int'
    => where {$_ >= 0}
    => message {"Wrong format for SecondsType: $_"};

has 'day' => (
    isa => 'DayType',
    is  => 'rw',
    default => 1,
    lazy => 1,
    trigger => \&__data_triger
);

has 'month' => (
    isa => 'MonthType',
    is  => 'rw',
    default => 1,
    lazy => 1,
    trigger => \&__data_triger
);

has 'year' => (
    isa => 'YearType',
    is  => 'rw',
    default => 1970,
    lazy => 1,
    trigger => \&__data_triger
);

has 'hours' => (
    isa => 'HoursType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_triger
);

has 'minutes' => (
    isa => 'MinutesType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_triger
);

has 'seconds' => (
    isa => 'SecondsType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_triger
);

has 'format' => (
    isa => 'Str',
    is  => 'rw',
    default => "%a %b %e %T %Y"
);

has 'epoch' => (
    isa => 'EpochType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__epoch_triger
);

sub __data_triger {
    my ($self, $nv, $ov) = @_;
    if (not defined $ov or $nv != $ov) {
        $self->epoch(timegm($self->seconds, $self->minutes, $self->hours, $self->day, $self->month  - 1, $self->year - 1900));
    }
}

sub __epoch_triger {
    my ($self, $nv, $ov) = @_;
    if (not defined $ov or $nv != $ov) {
         my @gmt_res = gmtime($nv);
         $self->seconds($gmt_res[0]);
         $self->minutes($gmt_res[1]);
         $self->hours($gmt_res[2]);
         $self->day($gmt_res[3]);
         $self->month($gmt_res[4] + 1);
         $self->year(1900 + $gmt_res[5]);
    }  
}

sub data_str_format {
    my ($self) = @_;
    return strftime($self->format, gmtime($self->epoch));
}

sub data_num_format {
    my ($self) = @_;
    return $self->epoch;
}

sub data_add {
    my ($self, $other, $swap) = @_;

    if ($swap) {
        if (looks_like_number($other) && $other == 0) {
            return $self->data_num_format();
        }
        die "Invalid argument";
    }

    my $res;

    if (ref($other) eq "Local::Date::Interval") {
        $res = __PACKAGE__->new(epoch=> $self->epoch + $other->duration);        
    }
    elsif (looks_like_number($other)) {
        $res = $self->epoch + $other;
    }
    else {
        die "Invalid argument";
    }

    return $res;
}

sub data_sub {
    my ($self, $other, $swap) = @_;

    die "Invalid argument" if ($swap);

    my $res;

    if (ref($other) eq "Local::Date::Interval") {
        $res = __PACKAGE__->new(epoch => ($self->epoch - $other->duration));
    }
    elsif (ref($other) eq "Local::Date") {
        $res = Local::Date::Interval->new(duration => ($self->epoch - $other->epoch));
    }
    elsif (looks_like_number($other)) {	
        $res = $self->epoch - $other;
    }
    else {
        die "Invalid argument";
    }

    return $res;
}

sub data_add_s {
    my ($self, $other, $swap) = @_;

    die "Invalid argument" if ($swap);


    if (ref($other) eq "Local::Date::Interval") {
        $self->epoch($self->epoch + $other->duration);
    }
    elsif (looks_like_number($other)) {
        $self->epoch($self->epoch + $other);
    }
    else {
        die "Invalid argument";
    }

    return $self;
}

sub data_sub_s {
    my ($self, $other, $swap) = @_;

    die "Invalid argument" if ($swap);

    if (ref($other) eq "Local::Date::Interval") {
        $self->epoch($self->epoch - $other->duration);
    }
    elsif (looks_like_number($other)) {
        $self->epoch($self->epoch - $other);
    }
    else {
        die "Invalid argument";
    }

    return $self;
}

1;
