package Varsel::Authentication::Store::Network;

use strict;
use warnings;

use NetAddr::IP;
use Varsel::Authentication::User::Host;

our $VERSION = '0.0100';

=head1 NAME

Varsel::Authentication::Store::Network - Catalyst authentication store

=head1 SYNOPSIS

    __PACKAGE__->config(
        authentication  => {
            default_realm   => 'backend',
            realms          => {
                backend         => {
                    credential      => {
                        class           => '+Varsel::Authentication::Credential::Exists',
                    },
                    store           => {
                        class           => '+Varsel::Authentication::Store::Network',
                        subnets         => [
                            { network => '127.0.0.1',   cidr => '8' },
                            { network => '87.238.45.0', cidr => '26' },
                        ],
                    },
                },
            },
        },
    );

    sub login : Global {
        my ( $self, $c ) = @_;

        if ($c->authenticate(
                { ip_address => $c->req->address },
                'backend')
        ) {
            $c->res->body("Your IP Address is: " . $c->user->ip_address . "!");
        }
    }

=head1 DESCRIPTION

This authentication store class will provide a list of subnets for the
credential class L<Varsel::Authentication::Credential::Exists> which checks
if the client is within one of the allowed subnets.

=head1 CONFIGURATION

These are the following configuration options available.
The example is for a YAML file.

    authentication:
        default_realm: network
        realms:
            network:
                credential:
                    class:  +Varsel::Authentication::Credential::Exists
                store:
                    class:  +Varsel::Authentication::Store::Network
                    subnets:
                        -
                            network:    127.0.0.1
                            cidr:       8
                        -
                            network:    87.238.45.0
                            cidr:       26

The C<subnets> is a list of subnets allowed access.

=head1 METHODS

=head2 new($config, $app)

Creates a new L<Varsen::Authentication::Store::Network> object.
$config should be a hashref, which should contain the configuration options
listed in L</CONFIGURATION>.

It also sets a few sensible defaults.

=cut

sub new {
    my ( $class, $config, $app ) = @_;

    unless (defined($config) && ref($config) eq "HASH") {
        Catalyst::Exception->throw(__PACKAGE__ . " needs to be configured with a hashref.");
    }

    my %config_hash = %{$config};
    $config_hash{'subnets'}     ||= [];

    my $self = \%config_hash;
    bless $self, $class;
    return $self;
}

=head2 find_user($authinfo, $c)

Looks up a user by the credentials sent to C<< $c->authenticate >>.
The C<ip_address> parameter from the C<$authinfo> hashref is used.

Returns a user object if found.

=cut

sub find_user {
    my ( $self, $authinfo, $c ) = @_;
    my $ip_address = $authinfo->{'ip_address'};

    return $self->get_user_by_ip_address($ip_address);
}

=head2 get_user_by_ip_address($ip_address)

Looks up the clients IP address in the list of subnets.
Returns a user object if the address is within one of the subnets.

=cut

sub get_user_by_ip_address {
    my ( $self, $ip_address ) = @_;

    my $ipaddr  = NetAddr::IP->new($ip_address);

    for my $subnet (@{ $self->{'subnets'} }) {
        my $network = $subnet->{'network'} . '/' . $subnet->{'cidr'};

        if ( $ipaddr->within(NetAddr::IP->new($network)) ) {
            my $user = Varsel::Authentication::User::Host->new(
                $self,
                $ipaddr,
            );

            return $user;
        }
    }

    return;
}

=head2 for_session($c, $host)

Returns a string identifing the client host.

=cut

sub for_session {
    my ( $self, $c, $host ) = @_;
    return $host->ip_address;
}

=head2 from_session($c, $ip_address)

Looks up and returns a user object from the frozen data stored in session,
which is the IP address in the case of this class.

=cut

sub from_session {
    my ( $self, $c, $ip_address ) = @_;
    return $self->get_user_by_ip_address($ip_address);
}

=head2 user_supports()

This authentication store does not support sessions.
This is not a big loss, actually it is much cleaner, since we check the IP
address of the user, and we don't expect that one to change, and if it does,
we want the clients IP address to be checked again.

This can't be done right now because the current user object is queried by
controllers. The Host user object has no C<username> method/attribute, so it
fails when queried.

PERHAPS LATER:
Returns the value of L<< Varsel::Authentication::User::Host >>->supports(@_)

=cut

sub user_supports {
    my $self = shift;

    return {
        session  => 0,
    };

    #return Varsel::Authentication::User->supports(@_);
}

=head1 AUTHORS

Knut-Olav Hoven <hovenko@linpro.no>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as GNU GPL version 2.

=cut

1;
