# NAME

Amagi - JSON API Framework

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
    
    post '/item/:id' => sub {
        my ($app, $req) = @_;
        my $item_id = $req->captured->{id} or return $app->res_error(400, 'bad request');
        my $new_name = $req->param('name');
        my $sth = $app->component('DB')->prepare('UPDATE member SET name=? WHERE id=?');
        $sth->execute($new_name, $item_id);
        $sth->finish;
        {new_name => $new_name};
    };
    
    1;

then, your psgi file,

    use MyApp::API;
    MyApp::API->app;

# DESCRIPTION

Amagi is a minimalist JSON API Framework.

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>
