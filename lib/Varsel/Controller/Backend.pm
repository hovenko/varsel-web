package Varsel::Controller::Backend;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Backend - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 CONFIGURATION

=head2 realm

This parameter defined the authentication realm to use for authenticating
users to the backend. Please see the authentication store
L<Followme::Authentication::Store::Network> for details about authenticating
client hosts.

You need to set up an authentication realm in your preferred configuration file.

Example:

    __PACKAGE__->config(
        realm   => 'scheduler',
    );

=cut

__PACKAGE__->config(
    'realm' => 'scheduler',
);

=head1 METHODS

=head2 auto

This method checks the IP address of the client to match a list of valid
IP addresses. Only predefined subnets of where the card readers are located
are allowed and some hosts for testing and special cases.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    my %credentials = (
        'ip_address'    => $c->req->address,
    );

    my $realm   = $self->{'realm'};

    if ($c->authenticate(\%credentials, $realm)) {
        return 1;
    }

    $c->log->error("Not allowed access to backend!");
    $c->forward('/error', ['Ingen tilgang']);

    return;
}

=head2 default

This handles requests for unknown controllers and actions.
It displays an error page.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    
    $c->response->content_type('text/plain');
    $c->response->body("Not a valid action");
}

=head2 end

We are not using the default view (Template Toolkit) here in the backend.

=cut

sub end : Private {
    # Doing nothing
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
