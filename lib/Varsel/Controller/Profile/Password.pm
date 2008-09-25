package Varsel::Controller::Profile::Password;

use strict;
use warnings;
 
use Data::Dumper;
use Varsel::Verification;

use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Profile::Password - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 lost

Display a page where the user can request a new password.

=cut

sub lost : Local {
    my ( $self, $c, $email ) = @_;

    $c->stash->{'email'}    = $email;
    $c->stash->{'template'} = 'profile/password/lost.tt2';
}

=head2 lost_do

Generates and sends a token on email to the user, that the user must enter
to be able to change his/her password.

=cut

sub lost_do : Local {
    my ( $self, $c ) = @_;

    if ($c->req->method =~ m{^post$}i) {
        # TODO add a security token to protect agains email spam
        my $email   = $c->req->body_parameters->{'email'};

        if (!$email) {
            return $c->res->redirect( $c->uri_for('lost') );
        }

        my $token       = Varsel::Verification->generate(12);
        my $profile     = $c->model('Profile')->find_by_email($email);
        $profile->resetpasswordtoken($token);
        $c->model('Profile')->update($profile);

        $c->stash->{'token'}    = $token;

        my $emailcontent    = $c->model('Profile::Email::Password')
            ->lost_password_email(
                'email'     => $email,
            );

        $c->stash->{'email'}    = $emailcontent;

        $c->forward( $c->view('Email') );

        $c->res->redirect( $c->uri_for('/profile/password/reset', $email) );
        return;
    }

    $c->res->redirect($c->uri_for('/'));
}

=head2 reset

Display a page where the user can enter the token and the new password.

=cut

sub reset : Local {
    my ( $self, $c, $email ) = @_;

    $c->stash->{'email'}    = $email;
    $c->stash->{'template'} = 'profile/password/reset.tt2';
}

sub reset_do : Local {
    my ( $self, $c ) = @_;


    if ($c->req->method =~ m{^post$}i) {
        my $email       = $c->req->body_parameters->{'email'};
        my $token       = $c->req->body_parameters->{'token'};
        my $password    = $c->req->body_parameters->{'password'};
        my $password2   = $c->req->body_parameters->{'password2'};

        $c->stash->{'email'}    = $email;
        $c->stash->{'token'}    = $token;
        $c->stash->{'template'} = 'profile/password/reset.tt2';

        if (!$password) {
            # Missing password
            $c->stash->{'validation'} = {
                'password'  => 'Du må skrive inn et nytt passord',
            };
            return;
        }

        if ($password ne $password2) {
            # Passwords not equal
            $c->stash->{'validation'} = {
                'password2' => 'Du må samme passord to ganger',
            };
            return;
        }
        
        my $profile = $c->model('Profile')
            ->find_by_email($email);

        if (!$profile) {
            # Unknown email address
            $c->stash->{'validation'} = {
                'email'     => 'Ukjent e-postadresse. Har du registrert deg?',
            };
            return;
        }

        if ($profile->resetpasswordtoken ne $token) {
            $c->stash->{'validation'} = {
                'token'     => 'Feil verifiseringskode',
            };
            return;
        }

        my $digested_password   = $c->model('Profile')
            ->digest_password($password);

        $profile->resetpasswordtoken(undef);
        $profile->password($digested_password);

        $c->model('Profile')->update($profile);
    }

    # We redirect to the frontpage after updating the password or if the page
    # was requested with a GET request.
    $c->res->redirect($c->uri_for('/'));
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
