package Varsel::Controller::Logout;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    if ($c->req->method =~ /post/i) {
        $c->forward('do_logout');
    }

    $c->response->redirect(
        $c->uri_for('/')
    );
}

=head2 do_logout

This method logs the user out of the application.

=cut

sub do_logout : Private {
    my ( $self, $c ) = @_;
    $c->logout();
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
