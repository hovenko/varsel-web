package Varsel::Controller::User;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 notices

This action lists all the users notices that have not yet been processed, and
those that are being procesed (normally within 10 days of forecast).

=cut

sub notices : Path {
    my ( $self, $c ) = @_;

    my $user    = $c->user;

    my @notices = $c->model('ForecastNotice')
        ->find_by_user($user);

    $c->stash->{'notices'}  = \@notices;
    $c->stash->{'template'} = 'user/notices.tt2';
}

=head2 feeds

This action lists all the users registered feeds.

=cut

sub feeds : Local {
    my ( $self, $c ) = @_;

    my $user    = $c->user;

    my @feeds = $c->model('ForecastFeed')
        ->find_by_user($user);

    $c->stash->{'feeds'}    = \@feeds;
    $c->stash->{'template'} = 'user/feeds.tt2';
}

=head2 auto

This method makes sure only authenticated users are allowed access to this
controller.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    if (!$c->user) {
        $c->response->redirect(
            $c->uri_for('/login')
        );

        return;
    }

    return 1;
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
