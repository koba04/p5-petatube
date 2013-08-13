package PetaTube::Redis;
use strict;
use warnings;
use utf8;

use Redis;
use JSON::XS;

sub new {
    my ($class) = shift;

    my $redis =  Redis->new(
        name        => 'petatube',
        server      => 'localhost:6379',
        encoding    => undef,
    );
    bless { redis => $redis }, $class;
}

sub set {
    my ($self, $namespace, $key, $value, $expire) = @_;

    my $make_key = $self->_make_key($namespace, $key);
    $self->{redis}->set($make_key => encode_json($value));
    $self->{redis}->expire($make_key => $expire) if $expire;
}

sub get {
    my ($self, $namespace, $key) = @_;

    my $res = $self->{redis}->get($self->_make_key($namespace, $key));
    return unless $res;
    decode_json($res);
}

sub get_callback {
    my ($self, $namespace, $key, $cb, $expire) = @_;

    my $res = $self->get($namespace, $key);
    unless ( defined $res ) {
        $res = $cb->();
        $self->set($namespace, $key, $res, $expire);
    }
    return $res;
}

sub incr_score {
    my ($self, $namespace, $key) = @_;

    $self->{redis}->zincrby($namespace, 1, $key);
}

sub rank_range {
    my ($self, $namespace, $from, $to) = @_;

    $self->{redis}->zrevrange($namespace, $from, $to);
}

sub _make_key {
    my ($self, $namespace, $key) = @_;
    return sprintf("%s:%s", $namespace, $key);
}


1;
