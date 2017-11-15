package Local::Reducer::MinMaxAvgRes;


use strict;
use warnings;
use 5.10.0;
use Mouse;


has min => (
    is => 'rw',
    isa => 'Int',
);

has max => (
    is => 'rw',
    isa => 'Int',
);

has avg => (
    is => 'rw',
    isa => 'Num',
);


sub get_min {
    my ($self) = @_;
    return $self->min;
}

sub get_max {
    my ($self) = @_;
    return $self->max;
}

sub get_avg {
    my ($self) = @_;
    return $self->avg;
}


1;
