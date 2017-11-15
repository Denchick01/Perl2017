package Local::Reducer; 

use strict;
use warnings;
use 5.10.0;
use Mouse;

has source => ( 
    is => 'ro',
    isa => 'Object',
);

has row_class => (
    is => 'ro',
    isa => 'Str',
);

has initial_value => (
    is => 'ro',
    isa => 'Int',
    default => 0,
);

has reduced => (
    is => 'rw',
    isa => 'Int',
    lazy => 1,
    default => sub { my ($self) =@_;
                return $self->initial_value},
);

sub reduce_n {}
sub reduce_all {}

1;
