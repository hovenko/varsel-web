package Varsel::Model::YR::Forecast::Symbol::Stringify;

use strict;
use warnings;
use utf8;

use base 'Catalyst::Model';

=head1 NAME

Varsel::Model::YR::Forecast::Symbol::Stringify - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 symbols

A map (HASHREF) with symbol names in a human readable format.

The default values are written in Norwegian bokmål. The source of information
is U<< http://www.yr.no/om_yrno/1.1940495 >>.

=cut

__PACKAGE__->config(
    'symbols'       => {
        1               => 'sol/klarvær',
        2               => 'lettskyet',
        3               => 'delvis skyet',
        4               => 'skyet',
        5               => 'regnbyger',
        6               => 'regnbyger med torden',
        7               => 'sluddbyger',
        8               => 'snøbyger',
        9               => 'regn',
        10              => 'kraftig regn',
        11              => 'regn og torden',
        12              => 'sludd',
        13              => 'snø',
        14              => 'snø og torden',
        15              => 'tåke',
    }
);

=head1 METHODS

=head2 filter(B<$symbol_no>)

=cut

sub filter {
    my ( $self, $symbol_no ) = @_;

    my %symbols     = %{ $self->{'symbols'} };

    my $string      = $symbols{$symbol_no};

    return $string;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
