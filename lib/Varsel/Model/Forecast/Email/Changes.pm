package Varsel::Model::Forecast::Email::Changes;

use strict;
use warnings;

use base 'Varsel::Model::Forecast::Email';

=head1 NAME

Varsel::Model::Forecast::Email::Changes - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 template

The template to use for the first forecast email.

=head2 template_html

The template to use for the first forecast email in HTML format.
This is optional.

=cut

__PACKAGE__->config(
    'template'      => 'email/forecast/changes/plain.tt2',
    'template_html' => 'email/forecast/changes/html.tt2',
);

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
