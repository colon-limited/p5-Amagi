# NAME

Amagi - JSON API Framework

<div>
    <a href='https://travis-ci.org/colon-limited/p5-Amagi'><img src='https://travis-ci.org/colon-limited/p5-Amagi.svg?branch=master' alt='Travis CI Status' /></a>

    <a href='https://coveralls.io/github/colon-limited/p5-Amagi?branch=master'><img src='https://coveralls.io/repos/github/colon-limited/p5-Amagi/badge.svg?branch=master' alt='Coverage Status' /></a>
</div>

# SYNOPSIS

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

# DESCRIPTION

Amagi is a minimalist JSON API Framework.

# LICENSE

Copyright (C) COLON Company Limited.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>
