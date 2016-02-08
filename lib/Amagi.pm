package Amagi;
use 5.008001;
use strict;
use warnings;
use Amagi::Core;
use Exporter 'import';
our $VERSION = "0.01";
our @EXPORT = qw/get post put delete add_component amagi_init amagi app/;
our $AMAGI_INSTANCE;

sub amagi_init (;$) {
    my $config = shift;
    $config ||= {};
    $AMAGI_INSTANCE = Amagi::Core->new($config);
}

sub amagi () {
    $AMAGI_INSTANCE;
}

sub app () {
    $AMAGI_INSTANCE->app;
}

sub add_component ($$) {
    my ($name, $object) = @_;
    $AMAGI_INSTANCE->add_component($name, $object);
}

{
    no strict 'refs';
    no warnings 'redefine';
    for my $method (qw/get post put delete/) {
        *{__PACKAGE__.'::'.$method} = sub ($$) {
            my ($path, $code) = @_;
            $AMAGI_INSTANCE->add(method => $method, path => $path, code => $code);
        };
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Amagi - JSON API Framework

=head1 SYNOPSIS

In your api class,

    package MyApp::API;
    use Amagi;
    my $config = +{ name => 'MyApp' };
    my $dbh = ...;
     
    amagi_init $config;
    add_component DB => $dbh;
     
    get '/' => sub {
        my ($app, $req) = @_;
        {message => 'Hello, Amagi!'};
    };
     
    post '/item/{id:[0-9]+}' => sub {
        my ($app, $req) = @_;
        my $item_id = $req->captured->{id} or return $app->res_error(400, 'bad request');
        my $new_name = $req->param('name');
        my $sth = $app->component('DB')->prepare('UPDATE member SET name=? WHERE id=?');
        $sth->execute($new_name, $item_id);
        $sth->finish;
        {new_name => $new_name};
    };

    put '/member/' => sub {
        my ($app, $req) = @_;
        my $json_data = $req->json_content or return $app->res_error(400 => 'Bad Request');
        my $sth = $app->component('DB')->prepare('INSERT INTO member (`name`, `age`) VALUES (?, ?)');
        $sth->execute($json_data->{name}, $json_data->{age});
        $sth->finish;
        {message => 'registered'};
    };
     
    1;


then, your psgi file,

    use MyApp::API;
    MyApp::API->app;

=head1 DESCRIPTION

Amagi is a minimalist JSON API Framework.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

