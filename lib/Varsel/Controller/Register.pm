package Varsel::Controller::Register;

use strict;
use warnings;

use Data::Dumper;
use DateTime;

use base qw/Catalyst::Controller Class::Accessor::Fast/;

=head1 NAME

Varsel::Controller::Register - Catalyst Controller

=head1 DESCRIPTION

This handles the step by step registration wizzard for registering new users
with a weather forecast request.

=cut

my %VALID_STEPS = (
    'email'     => 1,
    'place'     => 2,
    'date'      => 3,
    'profile'   => 4,
    'complete'  => 5, # to display the complete message
);

my %VALID_FIELDS = (
    'email'     => [qw/email/],
    'place'     => [qw/geo/],
    'date'      => [qw/date time/],
    'profile'   => [qw/firstname lastname password password2 email email2/],
);

my $RE_DATE = qr{\d{4}-\d{2}-\d{2}};    # YYYY-MM-DD
my $RE_TIME = qr{\d{2}:\d{2}};          # HH:MM
my $DEFAULT_TIME    = '12:00';

my @JS_STEPS = qw/email place complete/;
my @JS_DATE_STEPS   = qw/date/;

=head1 CONFIGURATION

=head2 password

=head3 minlength

The minimum allowed length of a password for users.

=head2 default_step

The default step to render when trying to access an action that does not exist.

=head2 default_input_email

The default text to show in the input field for email addresses.
This should be a very short help text.

=cut

__PACKAGE__->config(
    'password'              => {
        'minlength'             => 6,
    },
    'default_step'          => 'email',
    'default_input_email'   => 'Your email address',
    'form_action'           => 'forecast',
);


=head1 METHODS

=head2 default

Default action, redirects to the first step.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->res->redirect( $c->uri_for('forecast') );
}

=head2 begin 

This is executed for each action in this class.
It will load the incoming parameters and validate them.

It also loads Javascripts that are needed for each step.

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

    my $reg         = $c->forward('build_register_struct');
    $self->register($reg);
    $self->form_step($reg->{'form_step'});

    # Only validate on post requests
    if ($c->forward('is_post')) {
        my $validation  = $c->forward('validate_register_struct', [$reg]);
        $c->stash->{'validation'}   = $validation;
        
        $c->forward('require_first_timer', [$reg]);
    }
    
    # We do not want the password to be automatically filled out in the form
    my %secure_register         = %$reg;
    delete $secure_register{'password'};
    delete $secure_register{'password2'};
    
    $c->stash->{'reg'}          = \%secure_register;
}

=head2 end

This method is called after all other actions for each request to this package.
It will load nessecary Javascripts for the correct steps.

It will render the default view.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
    
    my $render_step = $self->render_step();
    $render_step    ||= $self->{'default_step'};
    
    $c->forward('prepare_js_register');

    # Loading the maps
    #if (grep { $_ eq $render_step } @JS_STEPS) {
        $c->model('Javascripts')->add_script(qw/
            google-maps
            google-maps-loader
        /);
    #}
    
    # Loading the datetime picker
    #if (grep { $_ eq $render_step } @JS_DATE_STEPS) {
        $c->model('Javascripts')->add_script(qw/
            ui-datepicker
        /);
        
        my %css_ui_datepicker = (
            'url'   => $c->uri_for('/static/css/ui.datepicker.css'),
        );
        push @{ $c->stash->{'stylesheets'} }, \%css_ui_datepicker;
    #}

    $c->stash->{'form_action'}  = $c->uri_for(
        sprintf(
            '/register/%s',
            $self->{'form_action'}
        )
    );
}

=head2 require_first_timer(C<$reg>)

A registered user must be validated before using this service again.

If a registered, but not verified, user tries to register a new forecast
notice request, the user is redirected to the verification page.

If the user enters a registered and verified email address, but is not logged
in, the user is redirected to the login page.

=cut

sub require_first_timer : Private {
    my ( $self, $c, $reg ) = @_;
    
    # A registered user must be validated before using the service again.
    my $registered = $c->model('Profile::Register')
        ->find_by_email($reg->{'email'});
    
    if ($registered && ! $registered->verified) {
        # User exists but it not verified
        $c->response->redirect(
            $c->uri_for('/verify',
                {
                    'email' => $reg->{'email'},
                }
            )
        );
    }
    elsif ($registered && ! $c->user) {
        # User exists but is not logged in
        $c->response->redirect(
            $c->uri_for('/login',
                {
                    'email' => $reg->{'email'},
                }
            )
        );
    }
}

=head2 prepare_js_register

This prepares the javascripts for loading on the register pages.

This loads the jQuery Javascript library and the Register Javascript.

=cut

sub prepare_js_register : Private {
    my ( $self, $c ) = @_;
    
    # Loading the register javascript
    $c->model('Javascripts')->add_script(qw/
        register
    /);
    
    $c->stash->{'def_email_input'}  = $self->{'default_input_email'};
}

=head2 email

Action that handles the entered email address.

=cut

sub email : Private {
    my ( $self, $c ) = @_;

    $self->render_step('email');
    $c->stash->{'template'} = 'register/email.tt2';

    if ($c->forward('is_post')) {
        my $email       = $c->stash->{'reg'}->{'email'};
        my $validation  = $c->stash->{'validation'};
        $validation     = $c->forward('filter_validations', [$validation]);
        
        if (%$validation) {
            $c->detach('redo_step');
        }
    }
    else {
        #
        # This method supports both post and get requests, and we need to
        # override. We want to render the same template as the action name
        # instead of the "next" one.
        #
        # If an email parameter is given, we autofil the form input field.
        #
        $c->stash->{'reg'}->{'email'} = $c->req->parameters->{'email'};
    }
}

=head2 place

Action that handles the selected location of the weather forecast.

=cut

sub place : Private {
    my ( $self, $c ) = @_;

    $self->render_step('place');
    $c->stash->{'template'} = 'register/place.tt2';
    
    my $validation  = $c->stash->{'validation'};
    $validation     = $c->forward('filter_validations', [$validation]);
    if (%$validation) {
        $c->detach('redo_step');
    }
}

=head2 date

Action that handles the date and time input.

=cut

sub date : Private {
    my ( $self, $c ) = @_;
    
    $self->render_step('date');
    $c->stash->{'template'} = 'register/date.tt2';

    my $validation  = $c->stash->{'validation'};
    $validation     = $c->forward('filter_validations', [$validation]);
    if (%$validation) {
        $c->detach('redo_step');
    }
}

=head2 profile

Action that handles the profile input.

=cut

sub profile : Private {
    my ( $self, $c ) = @_;

    $self->render_step('profile');
    $c->stash->{'template'} = 'register/profile.tt2';

    my $validation  = $c->stash->{'validation'};
    $validation     = $c->forward('filter_validations', [$validation]);
    if (%$validation) {
        $c->detach('redo_step');
    }
    
}

=head2 forecast

Action that handles will save the registered data to database.

=cut

sub forecast : Local {
    my ( $self, $c ) = @_;

    if ($c->forward('is_post')) {

        # Any of these steps will break out if there are any validation errors
        $c->forward('email');
        $c->forward('place');
        $c->forward('date');
        $c->forward('profile');
        

        if (my $user = $c->user) {
            # User is logged in

            my %register = %{ $self->register };
            
            my $profile = $c->model('Profile')->find_by_email($user->email);

            my $geo             = $register{'geo'};
            my $point           = $c->model('GoogleMaps')->extract_geo($geo);
            my $forecasttime    = $self->get_timestamp(\%register);
            
            my %notice_data     = (
                'latitude'          => $point->{'latitude'},
                'longitude'         => $point->{'longitude'},
                'address'           => $register{'address'} || '',
                'forecasttime'      => $forecasttime,
                'profile'           => $profile,
            );

            my $notice  = $c->model('ForecastNotice')
                ->create(\%notice_data);

            $c->stash->{'profile'}      = $profile;
            $c->stash->{'notice'}       = $notice;

            # Replacing the geo registration value with a hash of
            # latitude and longitude for easier use in templates.
            $c->stash->{'reg'}->{'geo'} = $point;

            $c->forward('check_notice_forecast', [$notice]);

            $c->stash->{'template'} = 'register/complete_auth.tt2';
        }
        else {
            # We have a new user
            my %register = %{ $self->register };
            
            
            my %profile_data    = (
                'email'             => $register{'email'},
                'firstname'         => $register{'firstname'},
                'lastname'          => $register{'lastname'},
                'password'          => $register{'password'},
            );
            
            my $profile = $c->model('Profile')->create(\%profile_data);

            my %register_data   = (
                'id'                => $profile,
                'email'             => $profile->email,
            );

            my $registered  = $c->model('Profile::Register')
                ->create(\%register_data);
            

            my $geo             = $register{'geo'};
            my $point           = $c->model('GoogleMaps')->extract_geo($geo);
            my $forecasttime    = $self->get_timestamp(\%register);
            my %notice_data     = (
                'latitude'          => $point->{'latitude'},
                'longitude'         => $point->{'longitude'},
                'address'           => $register{'address'} || '',
                'forecasttime'      => $forecasttime,
                'profile'           => $profile,
            );

            my $notice  = $c->model('ForecastNotice')->create(\%notice_data);

            
            $c->stash->{'profile'}      = $profile;
            $c->stash->{'registered'}   = $registered;
            $c->stash->{'notice'}       = $notice;

            # Replacing the geo registration value with a hash of
            # latitude and longitude for easier use in templates.
            $c->stash->{'reg'}->{'geo'} = $point;
            
            my $email = $c->model('Profile::Email')
                ->verification_email(
                    'email' => $register{'email'},
                );
            
            $c->stash->{'email'} = $email;
            
            # The Email view reads from the stashed "email" value
            $c->forward( $c->view('Email') );

            $c->forward('check_notice_forecast', [$notice]);

            $c->stash->{'template'} = 'register/complete.tt2';
        }
    }
    else {
        $c->detach( $self->{'default_step'} );
    }
}

=head2 check_notice_forecast

This method checks if the time of the requested forecast notice is very close,
and will then handle a "last forecast" notice if it is.

If the forecast notice is within the limit of days to look for, it will handle
it as a "first forecast" notice.

=cut

sub check_notice_forecast : Private {
    my ( $self, $c, $notice ) = @_;

    my $forecast = undef;

    # Send out the last email now, if forecast time is very close
    if ($c->model('ForecastNotice')->no_further_intervals($notice)) {
        $notice->finished(1); # this gets updated when calling set_forecast
        $forecast = $c->forward(
            '/backend/forecastretrieval/handle_last_notice',
            [$notice]
        );
    }
    elsif ($c->model('ForecastNotice')->time_for_new($notice)) {
        $forecast = $c->forward(
            '/backend/forecastretrieval/handle_first_notice',
            [$notice]
        );
    }

    $c->model('ForecastNotice')->set_forecast($notice, $forecast)
        if $forecast;

    return $notice;
}

=head2 get_timestamp(B<STRING>)

This method parses a date string and returns a object reference to an instance
of L<DateTime>.

It takes the timestamp in the following format:
 YYYY-MM-DD HH:MM

=cut

sub get_timestamp {
    my ( $self, $args ) = @_;
    
    my $time = $args->{'time'};
    my $date = $args->{'date'};
    
    my $str = "$date $time";
    
    my ($year, $month, $day, $hour, $minute)
        = $str =~ m{
            (\d{4}) -
            (\d{2}) -
            (\d{2})
            \s
            (\d{2}) :
            (\d{2})
        }x;
    
    my $dt = DateTime->new(
        'year'      => $year,
        'month'     => $month,
        'day'       => $day,
        'hour'      => $hour,
        'minute'    => $minute,
        'time_zone' => 'local',
    );

    return $dt;
}

=head2 is_post

This method checks if the request method was POST. Returns true if it is,
nothing (false) otherwise.

=cut

sub is_post : Private {
    my ( $self, $c ) = @_;
    
    return 1 if $c->req->method =~ /^post$/i;
    return;
}

=head2 redo_step

This method will redo the current step. It sets the template for the current
executed action.

=cut

sub redo_step : Private {
    my ( $self, $c ) = @_;
    
    # Setting a new render template if we have validation errors
    my $validation = $c->stash->{'validation'};
    if ($validation) {
        my $action = $self->get_invalid_step($validation);

        $self->render_step( $self->form_step );
        $validation     = $c->forward('filter_validations', [$validation]);
        $c->stash->{'validation'} = $validation;
        
        $c->log->info("Missing input from user to complete registration."
                     ." Next step: $action.");
        $c->log->debug("Invalid input from user: ".Dumper $validation)
            if $c->debug;
    }
}

=head2 get_invalid_step(C<\%validation>)

This method returns the name of the step with the lowest number containing
validation errors.

=cut

sub get_invalid_step : Private {
    my ( $self, $validation ) = @_;
    
    my $lowest_step         = undef;
    my $lowest_step_name    = undef;
    
    # We search through all invalid fields
    for my $invalid_field (keys %$validation) {
        
        # We then iterate over all mappings between steps and required fields
        while (my ($step, $fields_ref) = each %VALID_FIELDS) {
            
            # If the invalid field is in the list of the current step in
            # iteration we check if this step has a lower number than a
            # previously matched step
            if (grep { $_ eq $invalid_field } @$fields_ref) {
                my $step_no = $VALID_STEPS{$step};
                
                if (!defined $lowest_step || $step_no < $lowest_step) {
                    $lowest_step        = $step_no;
                    $lowest_step_name   = $step
                }
            }
        }
    }
    
    return $lowest_step_name;
}

=head2 validate_register_struct(C<\%reg>)

This method validates all registered values. This will also check values which
will be entered for upcoming steps, but at the end it will call a method to
filter out those that does not apply to the current step.

All error messages are in Norwegian bokmål.

=cut

sub validate_register_struct : Private {
    my ( $self, $c, $reg ) = @_;
    
    my %validation = ();
    
    $c->model('Email')->is_valid_email($reg->{'email'}) || do {
        $validation{'email'} = 'Ugyldig e-postadresse';
    };
    
    $reg->{'email'} && $reg->{'email2'} && $reg->{'email'} eq $reg->{'email2'}
        || do {
        $validation{'email2'} = 'Du må skrive inn samme e-postadresse';
    };
    
    # If missing email, we remove the error message of email2, if any
    $reg->{'email'} || do {
        $validation{'email2'} = '';
    };
    
    $reg->{'firstname'} || do {
        $validation{'firstname'} = 'Mangler fornavn';
    };
    
    $reg->{'lastname'} || do {
        $validation{'lastname'} = 'Mangler etternavn';
    };
    
    $reg->{'geo'} || do {
        $validation{'geo'} = 'Mangler kartkoordinater';
    };
    
    validate_date_format($reg->{'date'}) || do {
        $validation{'date'} = 'Ugyldig format på dato';
    };
    
    validate_time_format($reg->{'time'}) || do {
        $validation{'time'} = 'Ugyldig format på klokkeslett';
    };
    
    # Overrides the previous date check if the date is not set at all
    $reg->{'date'} || do {
        $validation{'date'} = 'Mangler dato';
    };
    
    # If date and time is valid format, we check if it is a valid date.
    if (!$validation{'time'} && !$validation{'date'}) {
        $self->validate_date($reg->{'date'}, $reg->{'time'}) || do {
            $validation{'date'} = 'Ugyldig dato eller klokkeslett';
        };
    }
    
    # If date and time is valid format, we check if the datetime is in the
    # future or in the past. 
    if (!$validation{'time'} && !$validation{'date'}) {
        $self->validate_date_ahead($reg->{'date'}, $reg->{'time'}) || do{
            $validation{'date'} = 'Dato må være fram i tid';
        };
    };
    
    # Passwords check
    $reg->{'password'} && $reg->{'password2'}
        && $reg->{'password'} eq $reg->{'password2'} || do {
        $validation{'password2'} = 'Du må skrive inn samme passord to ganger';
    };
    
    $reg->{'password'}
        && length $reg->{'password'} >= $self->{'password'}->{'minlength'}
        || do {
        $validation{'password'} = 'Passordet du har valgt er for kort';
        delete $validation{'password2'};
    };
    
    $reg->{'password'} && length $reg->{'password'} || do {
        $validation{'password'} = 'Du må skrive inn et passord du ønsker å bruke';
        delete $validation{'password2'};
    };
    
    #my $validation_ref = $c->forward('filter_validations', [\%validation]);
    
    return \%validation;
}

=head2 validate_date_format(C<$date>)

This method checks if a date is on a valid format.

=cut

sub validate_date_format : Private {
    my ( $date ) = @_;
    return unless $date && $date =~ m{^${RE_DATE}$};
}

=head2 validate_time_format(C<$time>)

This method checks if a time is on a valid format.

=cut

sub validate_time_format : Private {
    my ( $time ) = @_;
    return unless $time && $time =~ m{^${RE_TIME}$};
}

=head2 validate_date(C<$date>, C<$time>)

This method checks if the date and time entered are valid.

=cut

sub validate_date : Private {
    my ( $self, $date, $time ) = @_;
    eval {
        my $dt  = $self->get_timestamp({date => $date, time => $time});
    };
    if ($@) {
        return 0;
    }
    
    return 1;
}

=head2 validate_date_ahead(C<$date>, C<$time>)

This method checks if a date and time is past current time.

=cut

sub validate_date_ahead : Private {
    my ( $self, $date, $time ) = @_;
    
    my $dt;
    my $now = DateTime->now(time_zone => 'local');
    
    eval {
        $dt  = $self->get_timestamp({date => $date, time => $time});
    };
    if ($@) {
        return 0;
    }
    
    return DateTime->compare($dt, $now) > 0 ? 1 : 0;
}

=head2 filter_validations(C<\%validation>)

If the current step is equal or higher than the configured validation steps,
we copy the validation error messages, if any, to a new hash which we will
return.

This makes sure we don't trigger errors which are not valid to the current step.

=cut

sub filter_validations : Private {
    my ( $self, $c, $validation ) = @_;
    
    my $action      = $self->render_step();
    my $step_no     = $VALID_STEPS{$action};
    
    my %new_validation = ();
    
    # Iterate over all the steps for the valid fields we have
    for my $name (keys %VALID_FIELDS) {
        my $field_step_no = $VALID_STEPS{$name};
        next unless $field_step_no;
        
        # If the step we are at is equal or higher to the one in the iteration,
        # we go forward
        if ($step_no >= $field_step_no) {
            
            # Iterates over all the fields for the current step in iteration,
            # and add the validation note that exist for that field, if any.
            for my $field (@{ $VALID_FIELDS{$name} }) {
                next unless exists $validation->{$field};
                
                $new_validation{$field} = $validation->{$field};
            }
        }
    }

    if ($c->user) {
        # A logged in user does not need to enter that much data
        my @fields = qw/email email2 firstname lastname password password2/;
        for my $field (@fields) {
            delete $new_validation{$field};
        }
    }
    
    return \%new_validation;
}

=head2 build_register_struct

This method builds a registration data structure of registered data along with
the steps.

=cut

sub build_register_struct : Private {
    my ( $self, $c ) = @_;
    
    my @fields      = qw/
        form_step
        email email2 firstname lastname
        geo address date time password password2 
    /;
    
    my %register = ();
    
    for my $field (@fields) {
        $register{$field} = $c->req->body_parameters->{$field}
            || $c->req->body_parameters->{'reg.'.$field};
    }
    
    if (my $user = $c->user) {
        $register{'firstname'}  = $user->firstname;
        $register{'lastname'}   = $user->lastname;
        $register{'email'}      = $user->email;
    }
    
    $register{'time'}       ||= $DEFAULT_TIME;
    $register{'form_step'}  ||= $self->{'default_step'};
    
    return \%register;
}

=head2 register(<\%reg>)

Accessor for the register data structure.

=cut

__PACKAGE__->mk_accessors(qw/register/);

=head2 render_step

Accessor for the name of the step to render (display).

=cut

__PACKAGE__->mk_accessors(qw/render_step/);

=head2 form_step

Accessor for the name of the form just POST-ed.

=cut

__PACKAGE__->mk_accessors(qw/form_step/);

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
