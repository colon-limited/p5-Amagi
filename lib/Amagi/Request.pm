package Amagi::Request;
use strict;
use warnings;
use parent 'Plack::Request';

sub captured {
    my $self = shift;
    $self->{captured};
}

1;
