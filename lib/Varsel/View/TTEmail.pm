package Varsel::View::TTEmail;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
        Varsel->path_to( 'root', 'src' ),
        Varsel->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',

    TIMER        => 0
});

=head1 NAME

Varsel::View::TTEmail - Catalyst TTSite View

=head1 SYNOPSIS

See L<Varsel>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;

