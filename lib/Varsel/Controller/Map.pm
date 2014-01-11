package Varsel::Controller::Map;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Map - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 forecast

This method displays a forecast on the map.
It takes one argument which is the ID of the forecast notice.

=cut

sub forecast : Local Args(1) {
    my ( $self, $c, $notice_id ) = @_;

    my $notice      = $c->model('ForecastNotice')->find_by_id($notice_id);

    if (!$notice) {
        $c->stash->{'template'} = 'map/missing_forecast.tt2';
        return;
    }

    my $forecast    = $notice->forecast;

    $forecast       = $c->model('Forecast')->filter_winddirection($forecast);
    $forecast       = $c->model('Forecast')->filter_symbol($forecast);

    $c->model('Javascripts')->add_script(qw/
        google-maps
        google-maps-loader
    /);

    $c->stash->{'forecast'}     = $forecast;
    $c->stash->{'notice'}       = $notice;
    $c->stash->{'template'}     = 'map/forecast.tt2';
}

=head2 find

This method presents a map that the user can navigate or search in to find
a location they want forecasts from.

After finding their location they can continue to the registration process or
get an RSS 2 feed for the next couple of days.

=cut

sub find : Local {
    my ( $self, $c ) = @_;

    if ($c->req->method =~ /^post$/i) {
        my $geo         = $c->req->body_parameters->{'geo'};
        my $geosearch   = $c->req->body_parameters->{'geosearch'};
        
        my $precision = ($c->user ? undef : 3);
        my $point   = $c->model('GoogleMaps')
            ->extract_geo($geo, $precision);

        $c->stash->{'geosearch'}    = $geosearch;
        $c->stash->{'geo'}          = $point;
        $c->stash->{'template'}     = 'map/find/service.tt2';
    }
    else {
        $c->stash->{'template'} = 'map/find.tt2';
    }
    
    $c->model('Javascripts')->add_script(qw/
        google-maps-loader
    /);

}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
