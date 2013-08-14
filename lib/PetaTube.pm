package PetaTube;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='3.85';
use 5.008001;

use PetaTube::DataStore;

sub data_store {
    my $self = shift;
    return $self->{__data_store} ||= PetaTube::DataStore->new;
}

1;
