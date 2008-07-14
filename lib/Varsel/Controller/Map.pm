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


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
