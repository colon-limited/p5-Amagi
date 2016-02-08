package Amagi::Request;
use strict;
use warnings;
use parent 'Plack::Request';
use JSON;
use Carp ();

our $serializer = JSON->new->utf8(1);

sub captured {
    my $self = shift;
    $self->{captured};
}

sub json_content {
    my $self = shift;
    if ($self->content_type !~ /\/json/i) {
        Carp::carp('Content-type is not matched to json. It is "'. $self->content_type .'"');
        return;
    }
    $serializer->decode($self->content);
}

1;
