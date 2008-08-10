package Varsel::Model::Forecast;

use strict;
use warnings;

use base qw/
    Catalyst::Model
    Class::Accessor::Fast
/;

=head1 NAME

Varsel::Model::Forecast - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 dbmodel

Name of the model representing the B<forecast> database table.
Do not include the C<Varsel::Model> prefix in the package name.

Defaults to C<YRDB::Forecast>.

=cut

__PACKAGE__->config(
    'dbmodel'       => 'YRDB::Forecast',
);

=head1 METHODS

=head2 create(C<\%forecast>)

This method inserts a new forecast into the database table B<forecast>.

It returns the forecast object after insert.

=cut

sub create {
    my ( $self, $forecast ) = @_;
    
    $forecast = $self->_model->create($forecast);
    $forecast->insert;
    
    $forecast   = $self->filter_winddirection($forecast);
    $forecast   = $self->filter_symbol($forecast);
    
    return $forecast;
}

=head2 filter_winddirection

This method filters the wind direction of a forecast to put a human friendly
string on it.

See configuration parameter B<directions> for degrees and strings.

=cut

sub filter_winddirection {
    my ( $self, $forecast ) = @_;
    
    my $c       = $self->_context;
    my $string  = $c->model('YR::Forecast::WindDirection::Stringify')
        ->filter($forecast->winddirection);
    
    $forecast->{'winddirection_string'} = $string;
    return $forecast;
}

=head2 filter_symbol(C<$forecast>)

This method filters the symbol of the forecast to put a human friendly string
on it.

=cut

sub filter_symbol {
    my ( $self, $forecast ) = @_;

    my $c       = $self->_context;
    my $string  = $c->model('YR::Forecast::Symbol::Stringify')
        ->filter($forecast->symbol_no);
    
    $forecast->{'symbol_string'}    = $string;
    return $forecast;
}

=head2 has_changed(C<$old_forecast>, C<$new_forecast>)

This method compares an old forecast with a new one to see if the forecast has
changed since last time.

There are some limits that must be crossed before we say that the forecast has
changed:

    symbol_no:
        The forecast has changed if the symbol changes
    
    precip_value:
        Grey-zone between 0.3 - 0.5
            (needs tweaking, are there other units than mm?)
        The forecast has only changed when crossing this zone
    
    temp_value:
        Over limit when new temperature is between -5 and 5 degrees (celcius)
            and is within 3 degrees of old temperature (needs tweaking)
            Otherwise within 5 degrees of old temperature (needs tweaking)
        The forecast has changed when crossing this limit
    
    fog:
        Grey-zone between 5 - 10 (in percent, needs tweaking)
        The forecast has changed when crossing this zone
    
    pressure:
        Grey-zone between 1002.0 - 999.0 (needs tweaking)
        The forecast has changed when crossing this zone
    
    cloudiness:
        Grey-zone between 40.0 - 60.0 (in percent)
        The forecast has changed when crossing this zone
    
    windspeed:
        Over limit when new wind speed is above 3.0 mps,
            50% below old or 100% above old (needs tweaking)
        The forecast has changed when crossing this limit

When there are changes to the forecast, this method returns a HASHREF where the
key is the property name of the data type, as listed above. Only the keys of
the data types that have changed are set.

If there is no changes to the forecast, false is returned.

=cut

sub has_changed {
    my ( $self, $old_forecast, $new_forecast ) = @_;
    
    my %changes = ();
    
    # Symbol
    $changes{'symbol_no'} = 1
        if $old_forecast->symbol_no != $new_forecast->symbol_no;
    
    # Precipitation
    $changes{'precip_value'} = 1
        if $self->passed_grey_zone(
            $old_forecast->precip_value,
            $new_forecast->precip_value,
            0.3,
            0.5
        );
    
    # Temperature between -5 to 5
    $changes{'temp_value'} = 1
        if (    $new_forecast->temp_value <= 5
            ||  $new_forecast->temp_value >= -5)
        && $self->passed_limits(
            $old_forecast->temp_value,
            $new_forecast->temp_value,
            $old_forecast->temp_value - 3,
            $old_forecast->temp_value + 3
        );
    
    # Temperature
    $changes{'temp_value'} = 1
        if $self->passed_limits(
            $old_forecast->temp_value,
            $new_forecast->temp_value,
            $old_forecast->temp_value - 5,
            $old_forecast->temp_value + 5
        );
    
    # Fog
    $changes{'fog'} = 1
        if $self->passed_grey_zone(
            $old_forecast->fog,
            $new_forecast->fog,
            5,
            10
        );
    
    # Pressure
    $changes{'pressure'} = 1
        if $self->passed_grey_zone(
            $old_forecast->pressure,
            $new_forecast->pressure,
            1002.0,
            999.0
        );
    
    # Cloudiness
    $changes{'cloudiness'} = 1
        if $self->passed_grey_zone(
            $old_forecast->cloudiness,
            $new_forecast->cloudiness,
            40.0,
            60.0
        );
    
    # Windspeed
    $changes{'windspeed'} = 1
        if $new_forecast->windspeed > 3.0
        && $self->passed_limits(
            $old_forecast->windspeed,
            $new_forecast->windspeed,
            $old_forecast->windspeed * 0.5,
            $old_forecast->windspeed * 2,
        );
    
    # Return a HASHREF of changes if there are any
    return \%changes if %changes;
    
    # No? Well, it hasn't changed then!
    return;
}

=head passed_grey_zone(C<$old>, C<$new>, C<$lower>, C<$upper>)

This checks if the old and new values have passed the upper and lower limits.

Use this when the limits are final values, independent of the old values.

Returns true if passed, otherwise false.

=cut

sub passed_grey_zone {
    my ( $self, $old, $new, $lower, $upper ) = @_;
    
    # Has the values passed the limits?
    if ($old <= $lower && $new >= $upper) {
        return 1;
    }
    elsif ($old >= $upper && $new <= $lower) {
        return 1;
    }
    
    return;
}

=head2 passed_limits(C<$old>, C<$new>, C<$lower>, C<$upper>)

This checks if the new values have passed the upper or lower limits.

Use this when the limits are based on the old values.

Returns true if passed, otherwise false.

=cut

sub passed_limits {
    my ( $self, $old, $new, $lower, $upper ) = @_;
    
    if ($new <= $lower || $new >= $upper) {
        return 1;
    }
    
    return;
}

=head2 ACCEPT_CONTEXT

This loads the database model for forecasts fetched from YR and stored in
local database.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    my $model = $c->model($self->{'dbmodel'});
    $self->_model($model);
    $self->_context($c);
    return $self;
}

# Accessor for the model object for the forecast database table
__PACKAGE__->mk_accessors(qw/_model/);

# Accessor for the context object.
__PACKAGE__->mk_accessors(qw/_context/);

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
