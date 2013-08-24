use strict;
use warnings;
use utf8;
use t::Util;
use Test::More;

use PetaTube;

subtest "isa" => sub {
    my $petatube = PetaTube->context;
    isa_ok $petatube, 'Amon2';
};

subtest 'redis' => sub {
    my $petatube = PetaTube->context;

    isa_ok $petatube->redis, 'PetaTube::Redis';
    is $petatube->redis, $petatube->redis, 'same object';
};

subtest 'youtube' => sub {
    my $petatube = PetaTube->context;

    isa_ok $petatube->youtube, 'WebService::YouTube::Lite';
    is $petatube->youtube, $petatube->youtube, 'same object';
};

subtest 'http' => sub {
    my $petatube = PetaTube->context;

    isa_ok $petatube->http, 'Furl';
    is $petatube->http, $petatube->http, 'same object';
};

done_testing;
