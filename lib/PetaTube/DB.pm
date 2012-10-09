package PetaTube::DB;

use strict;
use warnings;
use utf8;
use parent 'Teng';
use Config::Pit;

sub new {
    my $class = shift;
    my $config = pit_get('petatube.koba04.com', require => {
        dsn     => "your dsn",
        db_user => "your db user",
        db_pass => "your db pass",
    });
    die "Can't get db config"  unless $config;
    $class->SUPER::new(
        connect_info => [
            $config->{dsn},
            $config->{db_user},
            $config->{db_pass},
            { mysql_enable_utf8 => 1},
        ],
    );
}

1;
