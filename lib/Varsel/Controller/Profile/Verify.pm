package Varsel::Controller::Profile::Verify;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Profile::Verify - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    
    if ($c->req->method !~ /^post$/i) {
        $c->res->redirect( $c->uri_for('enter') );
    }
    
    my $code        = $c->req->body_parameters->{'code'};
    
    $c->forward('code', [$code]);
}

=head2 enter

Displays a form for the user to enter the verification code.

=cut

sub enter : Local {
    my ( $self, $c ) = @_;
    
    $c->stash->{'template'} = 'profile/verify/enter_code.tt2';
}

=head2 code

Accepts the code as a parameter and will try to validate the users code.
This is primarily used when the user clicks on the link in the email.

This is also called on a POST request to L</index>.

If the user is found by the unique verification code, we verify the user and
the user is authenticated. If the user is already verified we show the
verification confirmed page, but do not log the user in. This is to prevent
spambots to log in as other users.

=cut

sub code : Path Args(1) {
    my ( $self, $c, $code ) = @_;
    
    my $registered  = $c->model('Profile::Register')->find_by_code($code);
    
    if ($registered) {
        # We authenticate the user has not already been verified
        if (!$registered->verified) {
            $c->authenticate(
                {
                    'email' => $registered->email,
                },
                'verify',
            );
        }
        else {
            $c->log->warn(
                "The user has already been verified with the code $code. "
                ."Therefore we do not authenticate the user automatically."
            );
        }
        
        $c->model('Profile::Register')->verify($registered);
        $c->stash->{'template'} = 'profile/verify/verified.tt2';
    }
    else {
        $c->stash->{'code'}                 = $code;
        $c->stash->{'validation'}->{'code'} = 'Ikke godkjent';
        $c->detach('enter');
    }
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
