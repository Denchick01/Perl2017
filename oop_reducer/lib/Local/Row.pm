package Local::Row; 

use strict;
use warnings;
use 5.10.0;

    sub parse_str {}

    sub new {}

    sub get {
        my ($self, $name, $default) = @_;
     
        return $self->{$name} if (exists $self->{$name});
        return $default;
    }


1;
