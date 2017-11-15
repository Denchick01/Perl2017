package Local::Source::Text; 

use 5.10.0;
use strict;
use warnings;
use Mouse;
extends 'Local::Source';

has text => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has delimiter => (
    is => 'rw',
    isa => 'Str',
    default => "\n",
);

sub BUILD {
    my ($self) = @_;

    my $temp_d = $self->delimiter; 
    @{$self->array} = split "$temp_d", $self->text;
}


1;
