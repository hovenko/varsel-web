package Varsel::Controller::Terms;

use strict;
use warnings;

use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Terms - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'terms/terms.tt2';
}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
