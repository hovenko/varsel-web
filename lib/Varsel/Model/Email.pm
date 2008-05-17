package Varsel::Model::Email;

use strict;
use warnings;

use Data::Validate::Email;

use base qw/Catalyst::Model/;

=head1 NAME

Varsel::Model::Email - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head2 is_valid_email(C<$email>)

Checks if the given email address is valid.

=cut

sub is_valid_email {
    my ( $self, $email ) = @_;
    
    return 1 if $email && Data::Validate::Email::is_email($email);
    return;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
