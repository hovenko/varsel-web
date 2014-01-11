package Varsel::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

This displays the login form.

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    if ($c->user) {
        $c->response->redirect(
            $c->uri_for('/')
        );
    }

    if ($c->req->method =~ /post/i) {
        $c->detach('do_login');
    }
    else {
        my $email   = $c->req->parameters->{'email'} || '';
        $c->stash->{'email'}    = $email;
        $c->stash->{'template'} = 'login.tt2';
    }
}

sub do_login : Private {
    my ( $self, $c ) = @_;
    
    my $email   = $c->req->body_parameters->{'email'} || '';
    my $pass    = $c->req->body_parameters->{'password'} || '';

    my $registered = $c->model('Profile::Register')
        ->find_by_email($email);

    if ($registered && !$registered->verified) {
        $c->log->debug("User with email address $email has not verified");
        $c->response->redirect(
            $c->uri_for('/verify',
                {
                    'email' => $email,
                }
            )
        );

        return;
    }

    my $user = $c->authenticate(
        {
            'email'     => $email,
            'password'  => $pass,
        },
        'members'
    );
    
    if (!$user) {
        $c->log->info("User $email entered wrong email or password");
        $c->stash->{'validation'}->{'login'} = 'Feil brukernavn eller passord';
        $c->stash->{'email'}    = $email;
        $c->stash->{'template'} = 'login.tt2';
    }
    else {
        $c->response->redirect(
            $c->uri_for('/')
        );
    }
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
