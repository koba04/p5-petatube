use strict;
use warnings;
use utf8;
use t::Util;
use Test::More;

use PetaTube;

my $c = PetaTube->context;

subtest 'redis' => sub {
    isa_ok $c->redis, 'PetaTube::Redis';
    isa_ok $c->redis->redis, 'Redis';
    ok $c->redis->redis->ping;
};

subtest 'set and get' => sub {
    $c->redis->set("test_petatube", test_set => { key => "hoge" });
    is_deeply $c->redis->get("test_petatube", "test_set"), { key => "hoge" }, "get the set value";

    subtest 'set expire' => sub {
        $c->redis->set("test_petatube", test_expire => { key => "hoge" }, 1);
        is_deeply $c->redis->get("test_petatube", "test_expire"), { key => "hoge" }, "not expire";
        sleep 2;
        is $c->redis->get("test_petatube", "test_expire"), undef, "expired";
    }
};

subtest 'get callback' => sub {
    my $called = 0;
    $c->redis->get_callback("test_petatube", get_callback => sub {
        $called = 1;
        return ['ok'];
    });
    ok $called, 'called callback';

    $called = 0;
    $c->redis->get_callback("test_petatube", get_callback => sub {
        $called = 1;
        return ['ok'];
    });
    ok !$called, 'not called callback';

    subtest 'set exipre' => sub {
        $called = 0;
        $c->redis->set("test_petatube", get_callback_with_expire => ['ok'], 1);
        $c->redis->get_callback("test_petatube", get_callback_with_expire => sub {
            $called = 1;
            return ['ok'];
        });
        ok !$called, 'not called callback';

        sleep 2;

        $c->redis->get_callback("test_petatube", get_callback_with_expire => sub {
            $called = 1;
            return ['ok'];
        });
        ok $called, 'expired, called callback';
    };
};

subtest 'incr_score and rank_range' => sub {

    $c->redis->incr_score('test_rank', 'score_1');
    $c->redis->incr_score('test_rank', 'score_3', 3);
    $c->redis->incr_score('test_rank', 'score_2', 2);
    $c->redis->incr_score('test_rank', 'score_4', 4);

    is_deeply
        [ $c->redis->rank_range('test_rank', 1 => 5) ],
        [qw/score_4 score_3 score_2 score_1/],
        'sorted rank'
    ;

    is_deeply
        [ $c->redis->rank_range('test_rank', 1 => 2) ],
        [qw/score_4 score_3/],
        'get rank1 and 2'
    ;

};


done_testing;
