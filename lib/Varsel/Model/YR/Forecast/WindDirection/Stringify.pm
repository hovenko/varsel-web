package Varsel::Model::YR::Forecast::WindDirection::Stringify;

use strict;
use warnings;
use utf8;

use base 'Catalyst::Model';

=head1 NAME

Varsel::Model::YR::Forecast::WindDirection::Stringify - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 directions

A map with degrees as key and a human readable format for the direction as
value.

The wind direction is a number from 0 to 360
(or 359.9, I don't really know, don't care, it doesn't matter).

The default values are written in Norwegian bokmål.
A direction is one of the following based on the direction the wind blows:
    nord
    nord-øst
    sør-øst
    sør
    sør-vest
    vest
    nord-vest

=cut

__PACKAGE__->config(
    'directions'    => {
        0               => 'nord',
        22.5            => 'nord-øst',
        67.5            => 'øst',
        112.5           => 'sør-øst',
        157.5           => 'sør',
        202.5           => 'sør-vest',
        247.5           => 'vest',
        292.5           => 'nord-vest',
        337.5           => 'nord',
    }

);

=head1 METHODS

=head2 filter(B<$winddirection>)

=cut

sub filter {
    my ( $self, $winddirection ) = @_;

    my %directions  = %{ $self->{'directions'} };

    my $current     = undef;

    while (my ($deg, $string) = each %directions) {
        $current    = $string
            if $winddirection >= $deg;
    }

    return $current;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
