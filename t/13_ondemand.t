use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

{
    package OreoreApp;
    use Amagi;

    add_component BlackBox => bless( sub { (shift() + 3) * 2 }, 'MyTest::Component' );

    get '/' => sub {
        my ($app, $req) = @_;
        {
            message => 'yay!', 
            appname => 'MyTest',
        };
    };

    post '/member/:id' => sub {
        my ($app, $req) = @_;
        my $id = $req->captured->{id};
        {
            message => 'id is '.$id, 
            name    => $req->param('name'),
            calc    => $app->component('BlackBox')->($id),
        };
    };

    no Amagi;
    1;
};

my $amagi = OreoreApp->amagi;

isa_ok $amagi, 'Amagi::Core';
can_ok $amagi, qw/get post delete put config components component add_component/;

my $test = Plack::Test->create($amagi->app);

subtest 'normal get' => sub {
    my $res = $test->request(GET '/');
    like $res->content, qr/"message":"yay!"/;
    like $res->content, qr/"appname":"MyTest"/;
    like $res->content, qr/"status":200/;
};

subtest 'normal post with capture' => sub {
    my $res = $test->request(POST '/member/123', [name => 'ytnobody']);
    like $res->content, qr/"message":"id is 123"/;
    like $res->content, qr/"name":"ytnobody"/;
    like $res->content, qr/"calc":252/;
    like $res->content, qr/"status":200/;
};

subtest '404 case' => sub {
    my $res = $test->request(PUT '/');
    like $res->content, qr/"message":"Not Found"/;
    like $res->content, qr/"status":404/;
    is $res->header('Content-type'), 'application/json; charset=utf-8';
    is $res->header('Content-length'), '36';
};

done_testing;
