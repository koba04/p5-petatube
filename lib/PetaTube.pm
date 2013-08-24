package PetaTube;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='3.85';
use 5.008001;

use PetaTube::Redis;

sub redis {
    my $self = shift;
    return $self->{__redis} ||= PetaTube::Redis->new(
        redis => Redis->new($self->config->{redis}),
    );
}

1;
__END__
=head1 NAME PetaTube

=head1 DESCRIPTION

  PetaTube's Context

=head1 SYNOPSYS

    my $c = PetaTube->context;
    my $data_store = $c->data_store;

=head1 METHODS

=over 4

=item my $data_store = $c->data_store

    return PetaTube::DataStore instance


