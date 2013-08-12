package PetaTube;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='3.85';
use 5.008001;

use Redis;

sub redis {
    my $self = shift;

    return $self->{__redis} ||= Redis->new(
        name        => 'petatube',
        server      => 'localhost:6379',
        encoding    => undef,
    );
}

1;
