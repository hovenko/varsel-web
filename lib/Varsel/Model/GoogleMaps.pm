package Varsel::Model::GoogleMaps;

use strict;
use warnings;
use base 'Catalyst::Model';

=head1 NAME

Varsel::Model::GoogleMaps - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 key

The API key needed to use the Google Maps API.
This has no default value and must be set in the configuration file.

=head2 url

The url must be a format string with one replacement value, C<%s> which
will be replaced with the L</key> configuration parameter.

Default value should be sufficient.

=cut

__PACKAGE__->config(
    'key'   => undef,
    'url'   => 'http://maps.google.com/maps?file=api&v=2&key=%s',
);

=head1 METHODS

=head2 javascript_url

Returns the complete URL to the Google Maps API Javascript code.

=cut

sub javascript_url {
    my ( $self ) = @_;
    
    return sprintf($self->{'url'}, $self->{'key'});
}

=head2 extract_geo(C<$geo>)

This method extracts the latitude and longitude from the geo coordinates
from a stringified Google Map point.

It returns a HASHREF with the keys B<latitude> and B<longitude>.

The format of C<$geo> is like this: B<< (<decimal>, <decimal>) >>

Example:
 (59.589106172938294, 10.213165283203125)

=cut

sub extract_geo {
    my ( $self, $geo ) = @_;
    
    my $RE_DECIMAL = qr{\d+ \. \d*}x;
    
    my ($lat, $long) = $geo =~ m{\A \( ($RE_DECIMAL) , \s* ($RE_DECIMAL) \) \z}xms;
    
    my $point = {
        'latitude'  => $lat,
        'longitude' => $long,
    };
    
    return $point;
}

=head2 ACCEPT_CONTEXT

Returns a reference to an instance of this class with the key and URL set
for the Google Maps Javascript.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    $self->{'key'}
        or Catalyst::Exception->throw("Missing key for Google Maps API");
    
    return $self;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
