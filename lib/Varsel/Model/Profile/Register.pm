package Varsel::Model::Profile::Register;

use strict;
use warnings;

use Params::Validate;

use base 'Catalyst::Model';

=head1 NAME

Varsel::Model::Profile::Register - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 dbmodel

Name of the model representing the B<profile> database table. Do not include
the C<Varsel::Model> prefix.

Defaults to C<YRDB::Profile>.

=cut

__PACKAGE__->config(
    'dbmodel'   => 'YRDB::Registered',
);

=head1 METHODS

=head2 create(C<\%register>)

Requires B<id> and B<email> to be set in the C<\%register> hash. The B<id>
parameter can either be the

The verification code is guarantied unique since we concatenate the 10 random
characters with the ID of the profile.

=cut

sub create {
    my $self = shift;

    my %register = validate(@_, {
        'id'    => {
            'type'  => Params::Validate::HASHREF | Params::Validate::SCALAR,
        },
        'email' => {
            'type'  => Params::Validate::SCALAR,
        },
    });
    
    my $id      = ref $register{'id'} ? $register{'id'}->id : $register{'id'};
    my $code    = $self->generate_code(10);
    
    # Concat the users ID and the code
    $register{'code'}   = sprintf('%d%s', $id, $code);

    my $register        = $self->_model->create(\%register);

    return $register;
}

=head2 find_by_email(B<$email>)

This looks up a registration by the users email address.

=cut

sub find_by_email {
    my ( $self, $email ) = @_;
    
    my $registered = $self->_model->search(
        {
            'email' => $email,
        },
    );
    
    return $registered->next;
}

=head2 find_by_code(B<$code>)

This looks up a registration by the users ID.

=cut

sub find_by_code {
    my ( $self, $code ) = @_;
    
    my $registered = $self->_model->search(
        {
            'code' => $code,
        },
    );
    
    return $registered->next;
}

=head2 verify(C<$registered>)

This verifies an email address. This allows the user to log in and register
more forecast notices.

=cut

sub verify {
    my ( $self, $registered ) = @_;
    
    $registered->verified(1);
    $registered->update;
    
    return $registered;
}

=head2 generate_code(C<$password_length>)

This generates a random code with a given length.
The code will contain only characters like A-Z, a-z and 0-9.

The default length is 10.

=cut

sub generate_code {
    my ($self, $password_length) = @_;

    $password_length ||= 10;

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

    for (my $i=0; $i < $password_length; $i++) {
        $_rand = int(rand scalar @chars);
        $password .= $chars[$_rand];
    }

    return $password;
}

=head2 ACCEPT_CONTEXT

This loads the database model.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    my $model = $c->model($self->{'dbmodel'});
    $self->_model($model);
    return $self;
}


# Accessor for the model object for the register database table
__PACKAGE__->mk_accessors(qw/_model/);


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
