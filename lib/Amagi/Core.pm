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

    my $res_data = $code->($self, $req) or return $self->res_error(500, 'Void Response');
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
