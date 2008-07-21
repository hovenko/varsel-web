package Varsel::Controller::Backend::ForecastRetrieval;

use strict;
use warnings;

use Data::Dumper;
use DateTime;

use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Backend::ForecastRetrieval - Catalyst Controller

=head1 DESCRIPTION

This controller will fetch forecasts for notices that are 10 (or less) days
ahead and forecasts for those users who have already gotten a forecast notice.

10 days is the default and is configurable.

It will send out updated forecasts for a given interval to users if the forecast
has changed since last forecast email.

=head1 METHODS

=head2 process_all

This action looks up all forecast notices that are valid for forecast updates.
It will then fetch the forecast from YR for each of the notices and send out
emails to the users.

=cut

sub process_all : Private {
    my ( $self, $c ) = @_;

    my $model       = $c->model('ForecastNotice');
    my @notices     = $model->find_ahead();
    my @processed   = ();
    my @forecasts   = ();
    
    foreach my $notice (@notices) {
        my $forecast = undef;
        
        if (!$notice->forecast) {
            $forecast = $c->forward('handle_first_notice', [$notice]);
            push @processed, $notice;
        }
        elsif ($model->is_last($notice)) {
            $notice->finished(1); # this gets updated when calling set_forecast
            $forecast = $c->forward('handle_last_notice', [$notice]);
            push @processed, $notice;
        }
        elsif ($notice->processed && $model->time_for_new($notice)) {
            $forecast = $c->forward('handle_notice', [$notice]);
            push @processed, $notice;
        }
        else {
            # It's not yet time for this notice, we'll wait
        }
        
        push @forecasts, $forecast
            if $forecast;
        
        $model->set_forecast($notice, $forecast)
            if $forecast;
    }
    
    my %response = (
        'procesed'      => \@processed,
        'forecasts'     => \@forecasts,
        'forecastdump'  => $c->stash->{'forecastdump'},
        'emaildump'     => $c->stash->{'emaildump'},
    );

    return \%response;
}

=head2 handle_first_notice(C<$notice>)

This method handles the first forecast notification.

We want to send out a welcome email telling that this will be the first forecast
email the user will receive.

It will send out the forecast only if the forecast if available for the
requested date and time.

=cut

sub handle_first_notice : Private {
    my ( $self, $c, $notice ) = @_;

    my $forecast    = $c->forward('get_forecast', [$notice]);
    
    if (!$forecast) {
        my $notice_id = $notice->id;
        $c->log->info(
            "Did not find any forecasts for notice $notice_id. "
            ."Maybe we tried to look too early..."
        );
        
        return;
    }
    
    my $profile = $notice->profile;
    
    $c->stash->{'forecast'}     = $forecast;
    $c->stash->{'profile'}      = $profile;
    $c->stash->{'notice'}       = $notice;
    
    my $email = $c->model('Forecast::Email::First')
        ->prepare_email(
            'email' => $profile->email,
        );
    
    $c->stash->{'email'} = $email;
    
    # Sends the email
    $c->forward( $c->view('Email') );
    
    # Just for debugging
    $c->stash->{'forecastdump'} = Dumper $forecast;
    $c->stash->{'emaildump'}    = Dumper $email;
    
    return $forecast;
}

=head2 handle_notice(C<$notice>)

This method handles forecast notifications of changed forecasts.

We want to send out an email telling the user that the forecast has changed
since last email and that he/she will continue to get emails about changes
until the requested time of forecast.

It will send out the forecast only if the forecast if available for the
requested date and time, which it should, since we have already sent out the
first forecast.

=cut

sub handle_notice : Private {
    my ( $self, $c, $notice ) = @_;
    
    my $forecast        = $c->forward('get_forecast', [$notice]);
    my $model           = $c->model('Forecast');
    
    if (!$forecast) {
        my $notice_id = $notice->id;
        $c->log->error(
            "Did not find any forecasts for notice $notice_id. "
            ."There is a bug somewhere. "
            ."We have already sent out the first forecast email..."
        );
        
        return;
    }
    
    # We only want to send out a new email if the forecast has changed since
    # last time.
    if (my $changes = $model->has_changed($notice->forecast, $forecast)) {
        my $profile = $notice->profile;
        
        $c->stash->{'forecast'}     = $forecast;
        $c->stash->{'profile'}      = $profile;
        $c->stash->{'notice'}       = $notice;
        $c->stash->{'changes'}      = $changes;
        
        my $email = $c->model('Forecast::Email::Changes')
            ->prepare_email(
                'email' => $profile->email,
            );
        
        $c->stash->{'email'}    = $email;
        
        
        # Sends the email
        $c->forward( $c->view('Email') );
        
        # Just for debugging
        $c->stash->{'forecastdump'} = Dumper $forecast;
        $c->stash->{'emaildump'}    = Dumper $email;
        
        return $forecast;
    }

    return;
}

=head2 handle_last_notice(C<$notice>)

This method handles the last forecast notifications.

We want to send out an email telling the user that this is the last notice
he/she will get for the requested forecast.

It will send out the forecast only if the forecast if available for the
requested date and time, which it should, since we have already sent out
previous forecasts.

=cut

sub handle_last_notice : Private {
    my ( $self, $c, $notice ) = @_;
    
    my $forecast    = $c->forward('get_forecast', [$notice]);
    
    if (!$forecast) {
        my $notice_id = $notice->id;
        $c->log->info(
            "Did not find any forecasts for notice $notice_id. "
            ."Maybe we tried to look too early..."
        );
        
        return;
    }
    
    my $profile = $notice->profile;
    
    $c->stash->{'forecast'}     = $forecast;
    $c->stash->{'profile'}      = $profile;
    $c->stash->{'notice'}       = $notice;
    
    my $email = $c->model('Forecast::Email::Last')
        ->prepare_email(
            'email' => $profile->email,
        );
    
    $c->stash->{'email'} = $email;
    
    # Sends the email
    $c->forward( $c->view('Email') );
    
    # Just for debugging
    $c->stash->{'forecastdump'} = Dumper $forecast;
    $c->stash->{'emaildump'}    = Dumper $email;
    
    return $forecast;
}

=head2 get_forecast(C<$notice>)

This method fetches the forecasts based on the location of the forecast notice
request.

It will then try to find the single forecast that is closest to the requested
time.

Then it stores the forecast in the database and returns the reference to it.

=cut

sub get_forecast : Private {
    my ( $self, $c, $notice ) = @_;
    
    my %geo        = (
        'longitude'     => $notice->longitude,
        'latitude'      => $notice->latitude,
    );

    my $yr_model        = $c->model('YR::Locationforecast');

    my $forecast_ref    = $yr_model->find_nearest_forecast(
        $notice->forecasttime,
        \%geo
    );
    
    my $model       = $c->model('Forecast');
    my $forecast    = $model->create($forecast_ref);
    
    return $forecast;
}

=head2 cron

This method is called from L<Catalyst::Plugin::Scheduler> to process all
forecast requests.

=cut

sub cron : Local {
    my ( $self, $c ) = @_;
    return $c->forward('process_all');
}

=head2 manual

This method can be called manually to process all forecast requests.
This should only be called when debugging.

=cut

sub manual : Local {
    my ( $self, $c ) = @_;
    my $response_ref = $c->forward('process_all');

    $c->response->content_type('text/plain');
    $c->response->body(Dumper $response_ref);
}

=head2 dump

A helper method to list the forecast notices that will be processed.

=cut

sub dump : Local {
    my ( $self, $c ) = @_;

    my $model       = $c->model('ForecastNotice');
    my @notices     = $model->find_ahead($self->{'lookahead'});
    
    $c->response->content_type('text/plain');
    $c->response->body(Dumper {
        'notices'       => \@notices,
    });
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
