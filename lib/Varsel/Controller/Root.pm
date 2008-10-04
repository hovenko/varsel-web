package Varsel::Controller::Root;

use strict;
use warnings;

use DateTime;

use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Varsel::Controller::Root - Root Controller for Varsel

=head1 DESCRIPTION

This is the main controller of L<Varsel>.

=head1 METHODS

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->forward('/register/prepare_js_register');
    
    if (my $user = $c->user) {
        $c->stash->{'user'}         = $user;
        $c->stash->{'reg'}          = { 'email' => $user->email };
        $c->stash->{'template'}     = 'index_auth.tt2';
    }
    else {
        $c->stash->{'template'} = 'index.tt2';
    }
}

=head2 default

This handles requests for unknown controllers and actions.
It displays an error page.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->detach('error', ['']);
}

=head2 error

Displays an error message.

=cut

sub error : Local {
    my ( $self, $c, $msg ) = @_;
    $c->stash->{'error'}    = $msg || "";
    $c->stash->{'template'} = 'error.tt2';
}

=head2 auto

This method is executed before all other actions.
This prepares the javascripts array.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    $c->stash->{'javascripts'} ||= $c->model('Javascripts');
    $c->stash->{'stylesheets'} ||= [];
    
    if (my $user = $c->user) {
        $c->stash->{'user'} = $user;
    }
    
    # Setting up default locale for date and time, if configured
    DateTime->DefaultLocale($c->config->{'locale'})
        if $c->config->{'locale'};
    
    
    return 1;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    # When rendering normal templates, we include the top banner
    $c->model('Banner::Top');
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
