package PetaTube::Redis;
use strict;
use warnings;
use utf8;

use Redis;
use JSON::XS;
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/redis/],
);

sub set {
    my ($self, $namespace, $key, $value, $expire) = @_;

    my $make_key = $self->_make_key($namespace, $key);
    $self->redis->set($make_key => encode_json($value));
    $self->redis->expire($make_key => $expire) if $expire;
}

sub get {
    my ($self, $namespace, $key) = @_;

    my $res = $self->redis->get($self->_make_key($namespace, $key));
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

    $self->redis->zincrby($namespace, 1, $key);
}

sub rank_range {
    my ($self, $namespace, $from, $to) = @_;

    # rank to index
    $from = $from - 1 if $from > 0;
    $to   = $to   - 1 if $to   > 0;

    $self->redis->zrevrange($namespace, $from, $to);
}

sub _make_key {
    my ($self, $namespace, $key) = @_;
    return sprintf("%s:%s", $namespace, $key);
}


1;
__END__
=head1 NAME PetaTube::Redis

=head1 DESCRIPTION

  PetaTube's dataStore.
  use Redis. (may chage?)

=head1 SYNOPSYS

    my $store = PetaTube::Redis->new;
    $store->set("hoge", "key", { name => "koba04" })
    my $person = $store->get("hoge", "key");

=head1 METHODS

=over 4

=item $store = PetaTube::Redis->new

  create instance

=item $store->set("namespace", "key", { name => "koba04" }, 60 * 60)

  set data (expire is optional)

=item $store->get("namespace", "key")

  get data

=item $store->get_callback("namespace", "key", sub { return { name => "koba04" } }, 60 * 60);

  get data. if can not get data, call subroutine and set returned value.
  (expire is optional)

=item $store->incr_score("namespace", "key")

  increment score

=item my $rank_data = $store->rank_range("namespace", "key", 1, 20)

  get ranking data between $from and $to

