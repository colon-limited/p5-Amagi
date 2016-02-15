package Amagi::Core;
use 5.008001;
use strict;
use warnings;
use Router::Boom;
use Digest::SHA;
use Class::Accessor::Lite (
    new => 0,
    ro => [qw/router config/],
    rw => [qw/controller components/],
);
use Amagi::Request;
use Amagi::Response;

sub new {
    my ($class, $config) = @_;
    $config ||= {};

    bless {
        config     => $config,
        router     => Router::Boom->new,
        controller => {},
        components => {},
    }, $class;
}

sub add {
    my ($self, %param) = @_;
    my $path = $param{path};
    my $method = $param{method};
    my $code = $param{code};
    my $action_id = Digest::SHA::sha256_hex($path);

    $self->controller->{$action_id}{$method} = $code;
    $self->router->add($path, $action_id);
}

{
    no strict 'refs';
    no warnings 'redefine';
    for my $method (qw/get post put delete/) {
        *{__PACKAGE__.'::'.$method} = sub {
            my ($self, $path, $code) = @_;
            $self->add(method => $method, path => $path, code => $code);
        };
    }
}

sub dispatch {
    my ($self, $env) = @_;
    my $req = Amagi::Request->new($env);
    my ($action_id, $captured) = $self->router->match($req->path);
    $req->{captured} = $captured;
    my $code = $self->controller->{$action_id}{lc($req->method)} or return $self->res_error(404, 'Not Found');

    my $res_data = eval { $code->($self, $req) };
    if ($@) {
        return $self->res_error(500, 'Internal Server Error : '. $@);
    }
    Amagi::Response->as_json($res_data);
}

sub res_error {
    my ($self, $status, $message) = @_;
    Amagi::Response->as_json({status => $status, message => $message});
}

sub add_component {
    my ($self, $name, $object) = @_;
    $self->components->{$name} = $object;
}

sub component {
    my ($self, $name) = @_;
    $self->components->{$name};
}

sub app {
    my $self = shift;
    sub {
        my $env = shift; 
        $self->dispatch($env);
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Amagi::Core - Amagi Core Class

=head1 SYNOPSIS

In your psgi file.

    use Amagi::Core;
    my $amagi = Amagi::Core->new(config => {appname => 'OreApp'});
    $amagi->get('/' => sub { 
        +{ appname => shift->config->{appname} } 
    } );
    $amagi->app;

=head1 ATTRIBUTE

=head2 config (HASHREF)

=head1 METHOD

=head2 get / post / put / delete

Add controller logic to router.

First argument is a path string, that specifies in L<lt>Router::Boom<gt> style.

Second argument is a code reference for controller logic.

    $amagi->get('/item/{id:[0-9]+}' => sub {
        my ($app, $req) = @_;
        ...
        +{ keyname => $value };
    });

=head2 res_error

Return L<lt>Amagi::Response<gt> object that contains passed status code and message.

    $amagi->post('/item/{id:[0-9]+}' => sub {
        my ($app, $req) = @_;
        return $app->res_error(400 => 'commit parameter is not defined') if !$req->param('commit');
        {message => 'ok'}
    });

=head1 CONTROLLER LOGIC

=head2 INCOMMING ARGUMENTS

Controller logic is passed 2 arguments.

First argument is an L<lt>Amagi::Core<gt> object.

Second argument is an L<lt>Amagi::Request<gt> object.

    $amagi->get('/' => sub {
        my ($app, $req) = @_;
        ### $app is an Amagi::Core object. $req is an Amagi::Request object.
        ...
    });

=head2 RESPONSE 

Controller logic must return hashref object.

=head1 LICENSE

Copyright (C) COLON Company Limited.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut


