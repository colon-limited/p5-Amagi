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
__END__

=encoding utf-8

=head1 NAME

Amagi::Response - Amagi Response Class

=head1 METHOD

=head2 as_json

Returns a finalized response that contains a json string that is encoded from passed hashref/arrayref .

=head1 LICENSE

Copyright (C) COLON Company Limited.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut
