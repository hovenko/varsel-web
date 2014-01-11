package Varsel::Controller::Feed::Register;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Feed::Register - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 register

This method registers a new feed for a location selected by the user.

=cut

sub register : Path {
    my ( $self, $c ) = @_;

    if ($c->req->method =~ m{^post$}i) {
        my $longitude   = $c->req->body_parameters->{'longitude'};
        my $latitude    = $c->req->body_parameters->{'latitude'};
        my $address     = $c->req->body_parameters->{'address'};

        if (my $user = $c->user) {
            my $profile = $c->model('Profile')->find_by_email($user->email);

            my %feed        = (
                'profile'       => $profile,
                'longitude'     => $longitude,
                'latitude'      => $latitude,
                'name'          => $address,
            );

            my $feed    = $c->model('ForecastFeed')->create(\%feed);

            $c->stash->{'feed'}     = $feed;
            $c->stash->{'template'} = 'register/feed/complete.tt2';
        }
        else {
            Catalyst::Exception->throw(
                "User is not logged in "
                ."and should not be able to access this method."
            );
        }
    }
    else {
        $c->log->debug("A user tried to register a feed using a GET request");
        $c->response->redirect(
            $c->uri_for('/')
        );
    }
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
