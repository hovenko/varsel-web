package Varsel::Controller::Feed::RSS2::Stored;

use strict;
use warnings;
use utf8;

use DateTime;

use base qw/
    Varsel::Controller::Feed::RSS2
/;

=head1 NAME

Varsel::Controller::Feed::RSS2::Stored - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 CONFIGURATION

=head2 hours

A list of hours (per day) to display feed for.

=head2 items

The number of items to display in the feed.

=head2 lifetime

Number of seconds to cache the feed content. Defaults to 6 hours.

=cut

__PACKAGE__->config(
    'hours'     => [ 10, 18 ],
    'items'     => 6,
    'lifetime'  => 3600 * 6,
);

=head1 METHODS

=head2 stored(B<$c>, B<$id>) 

This method prints a stored feed.
It will fetch a new forecast if it has expired (see configuration lifetime).

=cut

sub stored : Path Args(1) {
    my ( $self, $c, $id ) = @_;

    my $feed = $c->model('ForecastFeed')->find_by_id($id);

    Catalyst::Exception->throw("No such feed: $id")
        unless $feed;

    my $now     = DateTime->now('time_zone' => 'local');
    my $expires = $feed->processed;
    $expires->add('seconds' => $self->{'lifetime'});

    my $need_update = 0;
    $need_update    = 1 if DateTime->compare($now, $expires) > 0;
    $need_update    = 1 unless $feed->xmlcontent;

    if ($need_update) {
        my $content = $c->forward('fetch_feed', [$feed]);
        $feed->xmlcontent($content);
        $feed->processed($now);
    }

    $c->forward('/feed/rss2/print', [$feed->xmlcontent]);

    $feed->accessed($now);
    $c->model('ForecastFeed')->update($feed);
}

=head2 fetch_feed(B<$c>, B<$feed>)

This method fetches the forecasts and builds the RSS feed from a stored feed.

=cut

sub fetch_feed : Private {
    my ( $self, $c, $feed ) = @_;

    my %geo = (
        'longitude' => $feed->longitude,
        'latitude'  => $feed->latitude,
    );

    my @hours   = @{ $self->{'hours'} };
    my @times   = $self->get_times_list(
        $self->{'items'},
        @hours
    );

    my $rss     = $c->forward('/feed/rss2/rss2', [\%geo, @times]);

    my $feed_name   = $feed->name;
    $self->update_feed_description(
        $rss,
        "Værvarsel fra $feed_name"
    ) if $feed_name;

    my $content = $rss->as_string;

    return $content;
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
