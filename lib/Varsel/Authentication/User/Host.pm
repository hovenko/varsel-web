package Varsel::Authentication::User::Host;

use strict;
use warnings;

use base qw/
    Catalyst::Authentication::User
    Class::Accessor::Fast
/;

our $VERSION = '0.0100';

__PACKAGE__->mk_accessors(qw/user store/);


=head1 NAME

Varsel::Authentication::User::Host - Catalyst authentication user

=head1 DESCRIPTION

This authentication user class identifies a client computer authenticating with
the L<Varsel::Authentication::Store::Network> authentication store and credentials.

=cut

=head1 METHODS

=head2 new($store, $user)

Takes a L<Varsel::Authentication::Store::Network> object
as $store, and the data structure returned by that class's "find_user"
method as $user.

Returns a L<Catalyst::Authentication::User> object.

=cut

sub new {
    my ($class, $store, $user) = @_;

    return unless $store && $user;

    my %data = (
        'store' => $store,
        'user'  => $user,
    );

    my $self = bless \%data, $class;
    return $self;
}

=head2 id

Returns the identifier of the client host.

=cut

sub id {
    my ( $self ) = @_;
    return $self->ip_address;
}

=head2 ip_address

Returns the IP address of the client host.

=cut

sub ip_address {
    my ( $self ) = @_;
    return $self->user->addr;
}

=head2 supported_features

Returns hashref of features that this Authentication::User subclass supports.

It does not support sessions. See L<Varsel::Authentication::Store::Network>
for details.

It might support roles once in the future, but that is now only a thought.

=cut

sub supported_features {
    return {
#        session  => 0,
#        roles    => { self_check => 0, },
    };
}

=head2 get_object

Returns the underlying L<NetAddr::IP> object.

=cut

sub get_object {
    my ( $self ) = @_;
    return $self->user;
}

=head1 AUTHOR

Knut-Olav Hoven <hovenko@linpro.no>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as GNU GPL version 2.

=cut

1;
