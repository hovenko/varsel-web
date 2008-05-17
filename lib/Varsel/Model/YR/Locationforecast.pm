package Varsel::Model::YR::Locationforecast;

use strict;
use warnings;

use YR::Locationforecast;

use base 'Catalyst::Model';

=head1 NAME

Varsel::Model::YR::Locationforecast - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 latitude

The latitude coordinate of the location forecast. Must be supplied.

=head2 longitude

The longitude coordinate of the location forecast. Must be supplied.

=head1 METHODS

=head2 ACCEPT_CONTEXT

Returns the forcasts of YR location forecast web service.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c, $args ) = @_;

    $args ||= {};
    my %args = (%$args, %$self);
    
    my $yr = YR::Locationforecast->new(\%args);
    return $yr->forecast;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
