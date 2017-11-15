package Local::Source::FileHandle; 

use 5.10.0;
use strict;
use warnings;
use Mouse;

has fh => (
    is => 'ro',
    isa => 'GlobRef',
);


sub next {
    my ($self) = @_;
    my $line = readline($self->fh);
    return undef if (!$line);
    chomp $line;
    return $line;
}

1;
