package Varsel::Controller::Verify;

use strict;
use warnings;

use Data::Dumper;

use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Verify - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    
    my $email   = $c->req->parameters->{'email'};
    
    $c->stash->{'email'}    = $email;
    $c->stash->{'template'} = 'verify/index.tt2';
}

=head2 resend

This checks if the email address is valid and then sends a new verification
email to that address.

=cut

sub resend : Local {
    my ( $self, $c ) = @_;
    
    if ($c->req->method !~ /^post$/i) {
        $c->res->redirect( $c->uri_for('') );
    }
    
    my $email   = $c->req->body_parameters->{'email'};
    
    if ($c->model('Email')->is_valid_email($email)) {
        my $registered = $c->model('Profile::Register')->find_by_email($email);
        
        if (!$registered) {
            $c->detach('not_registered', [$email]);
        }
        elsif ($registered->verified) {
            $c->detach('already_verified');
        }
        
        $c->stash->{'registered'}   = $registered;
        
        my $email = $c->model('Profile::Email')
            ->verification_email(
                'email' => $email,
            );
        
        $c->stash->{'email'} = $email;
        $c->forward( $c->view('Email') );
        $c->stash->{'template'} = 'verify/email_sent.tt2';
    }
    else {
        $c->stash->{'validation'} = {
            'email' => 'Ugyldig e-postadresse',
        };
        
        $c->detach('index');
    }
}

=head2 not_registered

Displays a template to tell the user that he/she is not registered yet.

=cut

sub not_registered : Private {
    my ( $self, $c, $email ) = @_;
    
    $c->stash->{'email'}    = $email;
    $c->stash->{'template'} = 'verify/not_registered.tt2';
}

=head2 already_verified

Displays a template to tell the user that he/she is already verified and can
log in.

=cut

sub already_verified : Private {
    my ( $self, $c ) = @_;
    
    $c->stash->{'template'} = 'verify/already_verified.tt2';
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
