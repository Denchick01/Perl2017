package Local::Row::JSON; 

use strict;
use warnings;
use 5.10.0;
use parent 'Local::Row';

    sub parse_str {
        my $string = shift;
        my %params = ();       
        use JSON::XS;

        my $json_xs = JSON::XS->new()->utf8(1);

        eval {
            return $json_xs->decode($string);
        } or do {
            return undef;
        };

    }


    sub new {
       my ($class, %params) = @_;
          
       return undef if (!parse_str($params{str}) || ref(parse_str($params{str})) eq "ARRAY");
       return bless parse_str($params{str}), $class;
    }   

1;
