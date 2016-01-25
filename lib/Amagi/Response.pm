package Amagi::Response;
use strict;
use warnings;
use parent 'Plack::Response';
use JSON;

our $serializer = JSON->new->utf8(1);

sub as_json {
    my ($class, $data) = @_;
    $data->{status} ||= 200;
    my $res_data = $serializer->encode($data);
    my $res = $class->new(
        $data->{status}, 
        [
          'Content-type'   => 'application/json; charset=utf-8',
          'Content-length' => length($res_data),
        ], 
        [ $res_data ]
    );
    $res->finalize;
}

1;
