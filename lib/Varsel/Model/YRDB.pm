package Varsel::Model::YRDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Varsel::SchemaClass',
    connect_info => [
        'dbi:mysql:varsel',
        'varsel',
        'varsel',
        
    ],
);

=head1 NAME

Varsel::Model::YRDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<Varsel>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Varsel::SchemaClass>

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
