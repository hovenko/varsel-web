package Varsel::Verification;

use strict;
use warnings;

=head1 NAME

Varsel::Verification - Generate verification codes

=head1 DESCRIPTION

This package can generate random codes that can be used for verification in
the registration process or for lost passwords. It can also be used to generate
random passwords.

=head2 METHODS

=head2 B<< CLASS >>->generate_code(C<$length>)

This generates a random code with a given length.
The code will contain only characters like A-Z, a-z and 0-9.

The default length is 10.

=cut

sub generate {
    my ($class, $length) = @_;

    $length ||= 10;

    my $password;
    my $_rand;

    my @chars = qw(
a b c d e f g h i j k l m n o
p q r s t u v w x y z
A B C D E F G H I J K L M N O
P Q R S T U V W X Y Z
0 1 2 3 4 5 6 7 8 9
);

    srand;

    for (my $i=0; $i < $length; $i++) {
        $_rand = int(rand scalar @chars);
        $password .= $chars[$_rand];
    }

    return $password;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;

