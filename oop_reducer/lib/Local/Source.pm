package Local::Source; 

use 5.10.0;
use strict;
use warnings;
use Mouse;

has array => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub {[]},
);

has count => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

sub next {
    my ($self) = @_;
    my $temp = $self->count;
    $self->count($temp + 1);
    return $self->array->[$temp] if ($self->array->[$temp]);
    return undef;
}
     
1;
