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

done_testing;
