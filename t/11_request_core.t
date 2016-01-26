use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Amagi::Core;

my $config = {appname => 'MyTest'};
my $amagi = Amagi::Core->new($config);
my $component = bless( sub { (shift() + 3) * 2 }, 'MyTest::Component' );

isa_ok $amagi, 'Amagi::Core';
can_ok $amagi, qw/get post delete put config components component add_component/;

$amagi->add_component('BlackBox', $component);

$amagi->get('/', sub { 
    my ($app, $req) = @_;
    {message => 'yay!', appname => $app->config->{appname}};
});
$amagi->post('/member/:id', sub {
    my ($app, $req) = @_;
    my $id = $req->captured->{id};
    {
        message => 'id is '.$id, 
        name    => $req->param('name'),
        calc    => $app->component('BlackBox')->($id),
    };
});
$amagi->get('/err', sub {
    die 'my error';
});

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

subtest '500 case' => sub {
    my $res = $test->request(GET '/err');
    is $res->code, 500;
    like $res->content, qr/"message":"Internal Server Error : my error/;
};

done_testing;
