requires 'perl', '5.008001';
requires 'Router::Boom';
requires 'Plack';
requires 'JSON';
requires 'Class::Accessor::Lite';
requires 'Digest::SHA';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'HTTP::Request::Common';
};

