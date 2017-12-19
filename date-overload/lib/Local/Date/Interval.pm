package Local::Date::Interval;
use Mouse;
use 5.10.0;
use Mouse::Util::TypeConstraints;
use Scalar::Util qw(looks_like_number);

use overload
    '""' => 'data_interval_str_format',
    '0+' => 'data_interval_num_format',
    '+'  => 'data_interval_add',
    '-'  => 'data_interval_sub',
    '+=' => 'data_interval_add_s',
    '-=' => 'data_interval_sub_s',
    'fallback' => 1;


subtype 'InterDaysType'
    => as 'Int'
    => where {$_ >= 0}
    => message {"Wrong format for InterDayType: $_"};

subtype 'InterHoursType'
    => as 'Int'
    => where {$_ >= 0 && $_ <= 23}
    => message {"Wrong format for InterHoursType: $_"};

subtype 'InterMinutesType'
    => as 'Int'
    => where {$_ >= 0 && $_ <= 59}
    => message {"Wrong format for InterMinutesType: $_"};

subtype 'InterSecondsType'
    => as 'Int'
    => where {$_ >= 0 && $_ <= 59}
    => message {"Wrong format for InterSecondsType: $_"};


subtype 'InterDurationType'
      => as 'Int'
      => where { $_ >= 0 }
      => message {"Wrong format for InterDurationType: $_"};


has 'days' => (
    isa => 'InterDaysType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_elem_triger
);

has 'hours' => (
    isa => 'InterHoursType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_elem_triger
);

has 'seconds' => (
    isa => 'InterSecondsType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_elem_triger
);

has 'minutes' => (
    isa => 'InterMinutesType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__data_elem_triger
);

has 'duration' => (
    isa => 'InterDurationType',
    is  => 'rw',
    default => 0,
    lazy => 1,
    trigger => \&__duration_triger
);

sub __data_elem_triger {
    my ($self, $nv, $ov) = @_;
    if (not defined $ov or $nv != $ov) {
        $self->duration($self->days * 86400 + $self->seconds + $self->minutes * 60 + $self->hours * 3600);
    }
}

sub __duration_triger {
    my ($self, $nv, $ov) = @_;
    if (not defined $ov or $nv != $ov) {
        my $days  = int ($nv / 86400);
        my $temp_sec = $nv -  $days * 86400;
        my $hours = int($temp_sec / 3600);
           $temp_sec = $temp_sec - $hours * 3600;
        my $minutes = int($temp_sec / 60);
        $temp_sec = $temp_sec - $minutes * 60;
        my $seconds = $temp_sec;

        $self->days($days);
        $self->hours($hours);
        $self->minutes($minutes);
        $self->seconds($seconds);
    }
}

sub data_interval_str_format {
    my ($self) = @_;
    return $self->days . " days, " . $self->hours . " hours, " . $self->minutes . " minutes, " . $self->seconds . " seconds";
}

sub data_interval_num_format {
    my ($self) = @_;
    return $self->duration;
}

sub data_interval_add {
    my ($self, $other, $swap) = @_;

    if ($swap) {
        if (looks_like_number($other) && $other == 0) {
            return $self->data_interval_num_format();
        }
        die "Invalid argument";
    }

    my $res;

    if (ref($other) eq "Local::Date::Interval") {
        $res = __PACKAGE__->new(duration => ($self->duration + $other->duration));
    }
    elsif (looks_like_number($other)) {
        $res = $self->duration + $other;
    }
    else {
        die "Invalid argument";
    }

    return $res;
}

sub data_interval_sub {
    my ($self, $other, $swap) = @_;

    die "Invalid argument" if ($swap);

    my $res;

    if (ref($other) eq "Local::Date::Interval") {
        $res = __PACKAGE__->new(duration => ($self->duration - $other->duration));
    }
    elsif (looks_like_number($other)) {
        $res = $self->duration - $other;
    }
    else {
        die "Invalid argument";
    }

 
    return $res;
}

sub data_interval_add_s {
    my ($self, $other, $swap) = @_;

    die "Invalid argument" if ($swap);


    if (ref($other) eq "Local::Date::Interval") {
        $self->duration($self->duration + $other->duration);
    }
    elsif (looks_like_number($other)) {
        $self->duration($self->duration + $other);
    }
    else {
        die "Invalid argument";
    }

    return $self;
}

sub data_interval_sub_s {
    my ($self, $other, $swap) = @_;

    die "Invalid argument" if ($swap);

    if (ref($other) eq "Local::Date::Interval") {
        $self->duration($self->duration - $other->duration);
    }
    elsif (looks_like_number($other)) {
        $self->duration($self->duration - $other);
    }
    else {
        die "Invalid argument";
    }

    return $self;
}

1;
