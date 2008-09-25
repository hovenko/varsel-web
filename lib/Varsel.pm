package Varsel;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple

    Authentication
    Authorization::Roles

    Cache::FastMmap

    Scheduler

    Session
    Session::Store::FastMmap
    Session::State::Cookie

    PageCache
/;

our $VERSION = '0.21';

# Configure the application. 
#
# Note that settings in varsel.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    'name'          => 'Varsel',
    'default_view'  => 'TT',
);

# Start the application
__PACKAGE__->setup;


=head1 NAME

Varsel - Catalyst based application

=head1 SYNOPSIS

    script/varsel_server.pl

=head1 DESCRIPTION

Varsel is a service that sends out notification emails for forecasts when they
become available. This happens approximately 10 days before the actual day.

=head1 SEE ALSO

L<Varsel::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
