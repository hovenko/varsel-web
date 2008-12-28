package Varsel::Model::YR::Locationforecast;

use strict;
use warnings;

use Weather::YR::Locationforecast;

use base 'Catalyst::Model';

=head1 NAME

Varsel::Model::YR::Locationforecast - Catalyst Model

=head1 DESCRIPTION

Catalyst Model for accessing weather forecast from YR.no.

=head1 CONFIGURATION

=head2 latitude

The latitude coordinate of the location forecast. Optional.
Must be supplied with L</forecasts>.

=head2 longitude

The longitude coordinate of the location forecast. Optional.
Must be supplied with L</forecasts>.


=head1 VARIABLES

=head2 %TYPES

There are three types of forecast objects:
    Full
    Precip
    Symbol

=cut

our %TYPES  = (
    'Weather::YR::Locationforecast::Forecast::Full'      => 'full',
    'Weather::YR::Locationforecast::Forecast::Precip'    => 'precip',
    'Weather::YR::Locationforecast::Forecast::Symbol'    => 'symbol',
);
    

=head1 METHODS

=head2 forecasts(B<\%geo>)

Returns the forcasts of YR location forecast web service.

=cut

sub forecasts {
    my ( $self, $geo ) = @_;

    $geo ||= {};
    my %args = (%$geo, %$self);

    # HACK: make this configurable in yaml file
    $args{'url'} = "http://api.yr.no/weatherapi/locationforecast/1.5/";
    
    my $yr = Weather::YR::Locationforecast->new(\%args);
    return $yr->forecast;
}

=head2 find_nearest_forecast(C<$forecasttime>, C<\%geo>)

This method returns the closest forecast to a given date and time.

It first retrieves the entire weather forecast for a location, then
filters it to get the forecast types closest to a given date and time,
and then at last, combines the forecast types into one single forecast.

See L</forecasts> and L</filter_nearest_forecast> for details.

A HASHREF is returned.

=cut

sub find_nearest_forecast {
    my ( $self, $forecasttime, $geo_ref ) = @_;

    my $forecasts_ref   = $self->forecasts($geo_ref);

    my $forecast_ref    = $self->filter_nearest_forecast(
        $forecasttime,
        $forecasts_ref
    );

    $forecast_ref       = $self->combine_forecast_types($forecast_ref);

    return $forecast_ref;
}

=head2 filter_nearest_forecast(C<$forecasttime>, C<\@forecasts>)

This method looks through all forecasts to find the one closest to the requested
forecast notice time.

We want it all, so we find the ones closest from all these types.

If it gets a forecast type which we don't know, we throw an exception.

C<$forecasts_ref> is an ARRAYREF of forecasts, ordered by type of forecast
object, then by time.

This method returns a HASHREF of the nearest forecast of all the forecast types
(keys are in lower case).

=cut

sub filter_nearest_forecast {
    my ( $self, $forecasttime, $forecasts_ref ) = @_;
    
    my %nearest         = ();
    
    for my $forecast (@$forecasts_ref) {
        my $from    = $forecast->{'from'};
        
        my $cmp     = DateTime->compare($from, $forecasttime);
        my $type    = $TYPES{ref $forecast} || undef;
        
        if (!$type) {
            my $error = sprintf('Unknown forecast type: %s', ref $forecast);
            Catalyst::Exception->throw($error);
        }
        
        if ($cmp == 0) {
            # Perfect match on time
            $nearest{$type} = $forecast;
        }
        elsif ($cmp > 0) {
            # Very close. It's not perfect, but close enough.
            # We set the forecast unless it has been set before for this type.
            $nearest{$type} = $forecast unless $nearest{$type};
        }
        else {
            # Not yet there. Since we don't bother to check if we are close
            # "enough", like one hour until the requested time, we let it go...
        }
    }
    
    # We require all forecast data types to be there
    for my $type (values %TYPES) {
        Catalyst::Exception->throw("Missing forecast data for type $type")
            unless $nearest{$type};
    }
    
    return \%nearest;
}

=head2 combine_forecast_types(\%forecast)

This method combines the three forecast types (full, symbol and precip)
to one forecast HASH structure.

A HASHREF is returned.

=cut

sub combine_forecast_types {
    my ( $self, $forecast_ref ) = @_;

    my $fc_full     = $forecast_ref->{'full'};
    my $fc_symbol   = $forecast_ref->{'symbol'};
    my $fc_precip   = $forecast_ref->{'precip'};

    my %forecast    = (
        'fc_to'             => $fc_full->{'to'},
        'fc_from'           => $fc_full->{'from'},
        'latitude'          => $fc_full->{'location'}->{'latitude'},
        'longitude'         => $fc_full->{'location'}->{'longitude'},
        'altitude'          => $fc_full->{'location'}->{'altitude'},
        'fog'               => $fc_full->{'fog'}->{'percent'},
        'pressure'          => $fc_full->{'pressure'}->{'value'},
        'clouds_low'        => $fc_full->{'clouds'}->{'low'}->{'percent'},
        'clouds_medium'     => $fc_full->{'clouds'}->{'medium'}->{'percent'},
        'clouds_high'       => $fc_full->{'clouds'}->{'high'}->{'percent'},
        'cloudiness'        => $fc_full->{'cloudiness'}->{'percent'},
        'winddirection'     => $fc_full->{'winddirection'}->{'deg'},
        'windspeed'         => $fc_full->{'windspeed'}->{'mps'},
        'temp_unit'         => $fc_full->{'temperature'}->{'unit'},
        'temp_value'        => $fc_full->{'temperature'}->{'value'},
        'symbol_no'         => $fc_symbol->{'number'},
        'symbol_name'       => $fc_symbol->{'name'},
        'precip_unit'       => $fc_precip->{'unit'},
        'precip_value'      => $fc_precip->{'value'},
    );

    return \%forecast;
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
