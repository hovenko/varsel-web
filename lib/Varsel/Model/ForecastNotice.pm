package Varsel::Model::ForecastNotice;

use strict;
use warnings;

use DateTime;

use base qw/Catalyst::Model Class::Accessor::Fast/;

=head1 NAME

Varsel::Model::ForecastNotice - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 dbmodel

Name of the model representing the B<forecast_notice> database table.
Do not include the C<Varsel::Model> prefix in the package name.

Defaults to C<YRDB::ForecastNotice>.

=head2 lookahead

The number of days before the date ot the forecast notice request that the user
selected.

Defaults to 10 days.

=head2 interval

The number of days between each forecast update. From the first notice there
will be sent out one notice for each interval in days.

The default is every second day, aka. two days between each forecast update.

=cut

__PACKAGE__->config(
    'dbmodel'   => 'YRDB::ForecastNotice',
    'lookahead'     => '10',
    'interval'      => '2',
);


=head1 METHODS

=head2 create(C<\%forecast>)

This method inserts a new forecast notice into the database table
B<forecast_notice>.

It returns the forecast notice object after insert.

=cut

sub create {
    my ( $self, $forecast ) = @_;
    
    $forecast = $self->_model->create($forecast);
    $forecast->insert;
    
    return $forecast;
}

=head2 find_ahead(C<$days>)

This returns all the notification forecast requests that is within the given
number of days and has not yet been processed.

Parameter C<$days> is optional and defaults to configured value B<lookahead>.

=cut

sub find_ahead {
    my ( $self, $days ) = @_;

    $days       ||= $self->{'lookahead'};

    my $dt      = DateTime->now('time_zone' => 'local');
    my $now     = $dt->clone();
    $dt->add('days' => $days);

    my $notices = $self->_model->search(
        {
            'forecasttime'  => {
                '<='            => $dt,
            },
            'forecasttime'  => {
                '>'             => $now,
            },
            'finished'      => 0,
        }
    );

    return $notices->all;
}

=head2 find_by_user(C<$profile>)

This finds all notices for a user that have not yet started or are still in
process.

Parameter C<$profile> can be either a DBIC entity reference or a profile ID.

=cut

sub find_by_user {
    my ( $self, $profile ) = @_;

    my $uid     = ref $profile ? $profile->id : $profile;
    my $now     = DateTime->now('time_zone' => 'local');

    my $notices = $self->_model->search(
        {
            'profile'       => $uid,
            'finished'      => 0,
            'forecasttime'  => {
                '>'             => $now,
            },
        },
        {
            'order_by'      => 'forecasttime',
        }
    );

    return $notices->all;
}

=head2 time_for_new(C<$notice>, C<$days>)

This method returns a true value if the datetime is older than the interval.
Otherwise it returns false.

Parameter C<$days> is optional and defaults to configuration value B<interval>.

=cut

sub time_for_new {
    my ( $self, $notice, $days ) = @_;

    $days           ||= $self->{'interval'};
    my $datetime    = $notice->processed;

    my $limit = DateTime->now('time_zone' => 'local');
    $limit->subtract('days' => $days);

    return 1 if DateTime->compare($limit, $datetime) > 0;
    return;
}

=head2 is_last(C<$notice>)

This method checks if this is the last notice to handle.

It will return a true value if L</time_for_new> returns true and it is less
than B<interval> days left to selected date and time.

It will also return a true value of it is less than 1 day left and the current
time has passed 12:00 the day before.

Be ware that if a user requests a forecast the next day he might get the first
and last forecast email very close, like at the same time or an hour after.

Otherwise, it returns false.

=cut

sub is_last {
    my ( $self, $notice ) = @_;

    return 1
        if $self->time_for_new($notice)
        && $self->no_further_intervals($notice);

    return 1
        if $self->after_noon()
        && $self->no_days_left($notice);

    return;
}

=head2 no_further_intervals(C<$notice>)

This method checks if there are time for more intervals before the time the
user requested for the forecast.

It returns true if there are more than C<interval> days left to forecast time.

Returns false if not.

=cut

sub no_further_intervals {
    my ( $self, $notice ) = @_;
    
    my $next = DateTime->now('time_zone' => 'local');
    $next->add('days' => $self->{'interval'});
    
    # FIXME a possible bug is when the last notice happens at the same time as
    # the requested forecast time. You probably wont need a forecast update for
    # the present time.
    
    return 1
        if DateTime->compare($next, $notice->forecasttime) >= 0;
    
    return;
}

=head2 no_days_left(C<$notice>)

This method returns a true value if there are no days left until the requested
forecast date and time. More correct, it means it is less than 24 hours left.

Returns false if there are more than 1 day until the requested time.

=cut

sub no_days_left {
    my ( $self, $notice ) = @_;

    my $now             = DateTime->now('time_zone' => 'local');
    my $forecasttime    = $notice->forecasttime;

    $now->add('days' => 1);

    return 1 if DateTime->compare($now, $forecasttime) > 0;
    return;
}

=head2 after_noon

This method returns a true value if the current time has passed noon.

Returns false if not.

=cut

sub after_noon {
    my ( $self ) = @_;

    my $dt = DateTime->now('time_zone' => 'local');
    return 1 if $dt->hour > 12;
    return;
}

=head2 set_forecast(C<$notice>, C<$forecast>)

This method sets the notice as processed and updated the database.

=cut

sub set_forecast {
    my ( $self, $notice, $forecast ) = @_;

    $notice->processed(DateTime->now('time_zone' => 'local'));
    $notice->forecast($forecast);
    $notice->update;

    return $notice;
}

=head2 ACCEPT_CONTEXT

This loads the database model for forecast notices.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    my $model = $c->model($self->{'dbmodel'});
    $self->_model($model);
    
    return $self;
}


# Accessor for the model object for the database table
__PACKAGE__->mk_accessors(qw/_model/);


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
