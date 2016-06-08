package Amagi::Request;
use strict;
use warnings;
use parent 'Plack::Request::WithEncoding';
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
    my $json = eval { $serializer->decode($self->content) };
    if ($@) {
        Carp::carp($@);
        return;
    }
    return $json;
}

1;
__END__

=encoding utf-8

=head1 NAME

Amagi::Request - Amagi Request Class

=head1 SYNOPSIS

    get '/item/{id:[0-9]+}' => sub {
        my ($app, $req) = @_;
        my $item_id = $req->captured->{id};
        +{ item_id => $item_id };
    };


=head1 METHOD

=head2 captured

Returns a hashref that contains matched result values of L<lt>Router::Boom<gt>.

    get '/item/{id:[0-9]+}' => sub {
        my ($app, $req) = @_;
        my $item_id = $req->captured->{id};
        +{ item_id => $item_id };
    };


=head2 json_content

Returns a hashref that is decoded from content-body data if content-type is json.

    post '/item/{id:[0-9]+}' => sub {
        my ($app, $req) = @_;
        my $item_id = $req->captured->{id};
        my $name = $req->json_content->{name}
        +{ item_id => $item_id, name => $name };
    };


=head1 LICENSE

Copyright (C) COLON Company Limited.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

