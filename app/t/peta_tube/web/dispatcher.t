use strict;
use warnings;
use utf8;
use t::Util;
use Plack::Test;
use Plack::Util;
use Test::More;

use JSON::XS;

my $app = Plack::Util::load_psgi 'app.psgi';

subtest '/' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => 'http://localhost/');
            my $res = $cb->($req);
            is $res->code, 200;
            is $res->content_type, 'text/html';
            like $res->content, qr/PetaTube/;
        };

};

subtest '/videos/{id}' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => 'http://localhost/videos/0');
            my $res = $cb->($req);
            is $res->code, 200;
            is $res->content_type, 'application/json';
        };
};

subtest '/videos/' => sub {
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => 'http://localhost/videos/');
            my $res = $cb->($req);
            is $res->code, 200;
            is $res->content_type, 'application/json';
            is_deeply
                decode_json($res->content),
                {
                    video_ids   => [],
                    title       => '',
                    url         => '',
                },
        };
};


done_testing;
