package PetaTube;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='3.85';
use 5.008001;

use Furl;
use WebService::YouTube::Lite;
use PetaTube::Redis;

sub redis {
    my $self = shift;
    return $self->{__redis} //= PetaTube::Redis->new(
        redis => Redis->new($self->config->{redis}),
    );
}

sub youtube {
    my $self = shift;
    return $self->{__youtube} //= WebService::YouTube::Lite->new;
}

sub http {
    my $self = shift;
    $self->{__http} //= Furl->new(
        agent   => 'PetaTubeUA/1.0',
        timeout => 10,
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

=item my $youtube = $c->youtube

    return WebService::YouTube::Lite instance

=item my $http = $c->http

    return Furl instance

