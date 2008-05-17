package Varsel::Authentication::Credential::Exists;

use strict;
use warnings;

use base qw/Class::Accessor::Fast/;

=head1 NAME

Varsel::Authentication::Credential::Exists - Simple Catalyst credential

=head1 DESCRIPTION

This authentication credential class will check if the user exists in the store
by the given credentials.

=cut

__PACKAGE__->mk_accessors(qw/_config realm/);

our $VERSION = '0.0100';


=head1 METHODS

=head2 new($config, $app, $app, $realm)

Creates a new object.

=cut

sub new {
    my ( $class, $config, $app, $realm ) = @_;

    my $self    = { '_config' => $config };
    bless $self, $class;

    $self->realm($realm);

    return $self;
}

=head2 authenticate($c, $realm, $authinfo)

Looks up a user by the credentials sent to C<< $c->authenticate >>.
Returns a user object on successful authentication.

=cut

sub authenticate {
    my ( $self, $c, $realm, $authinfo ) = @_;

    my $user_obj = $realm->find_user($authinfo, $c);

    if (ref $user_obj) {
        return $user_obj;
    }
    else {
        $c->log->debug("Unable to locate user matching user info provided")
            if $c->debug;
        return;
    }
}

=head1 AUTHORS

Knut-Olav Hoven <hovenko@linpro.no>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as GNU GPL version 2.

=cut

1;
