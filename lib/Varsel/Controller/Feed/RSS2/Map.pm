package Varsel::Controller::Feed::RSS2::Map;

use strict;
use warnings;

use base qw/
    Varsel::Controller::Feed::RSS2
/;

=head1 NAME

Varsel::Controller::Feed::RSS2::Map - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 CONFIGURATION

=head2 hours

A list of hours (per day) to display feed for.

=head2 items

The number of items to display in the feed.

=cut

__PACKAGE__->config(
    'hours' => [ 10, 18 ],
    'items' => 6,
);

my $RE_POINT = qr{\d+ \. \d+}x;

=head1 METHODS

=head2 map($geo) 

This fetches the forecast for a location by the latitude and longitude.
This can be used by anonymous users.

=cut

sub map : Path Args(1) {
    my ( $self, $c, $geo ) = @_;

    my ($lat, $long) = $geo =~ m{\A ($RE_POINT) \+ ($RE_POINT) \z}xms
        or Catalyst::Exception->throw("Invalid geo coordinates: ${geo}");

    my %geo = (
        'longitude' => $long,
        'latitude'  => $lat,
    );


    my @hours = @{ $self->{'hours'} };

    my @times   = $self->get_times_list(
        $self->{'items'},
        @hours
    );

    my $rss     = $c->forward('/feed/rss2/rss2', [\%geo, @times]);

    $c->forward('/feed/rss2/print', [$rss->as_string]);
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
