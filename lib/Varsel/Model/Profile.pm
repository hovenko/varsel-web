package Varsel::Model::Profile;

use strict;
use warnings;

use Data::Dumper;
use Digest;

use base qw/Catalyst::Model Class::Accessor::Fast/;

=head1 NAME

Varsel::Model::Profile - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 dbmodel

Name of the model representing the B<profile> database table. Do not include
the C<Varsel::Model> prefix.

Defaults to C<YRDB::Profile>.

=head2 salt

The salt which is used to digest the users password.
This should be overridden in the configuration file, because the default value
is not secure at all.

=cut

__PACKAGE__->config(
    'dbmodel'   => 'YRDB::Profile',
    'hash_type' => 'SHA-1',
    'salt'      => 'ikke-fullt-hemmelig-salt',
);


=head1 METHODS

=head2 create(C<\%profile>)

This method inserts a new profile into the database table B<profile>.
It takes out only the parameters it needs from the HASHREF profile parameter.

It returns the profile object after insert.

=cut

sub create {
    my ( $self, $profile ) = @_;
    
    $profile->{'password'}  = $self->digest_password($profile->{'password'});
    $profile                = $self->_model->create($profile);
    $profile->insert;

    # Should not have to deal with passwords after this
    delete $profile->{'password'};
    
    return $profile;
}

=head2 find_by_email(B<$email>)

This looks up a user by its email address.

=cut

sub find_by_email {
    my ( $self, $email ) = @_;
    
    my $profile = $self->_model->search(
        {
            'email' => $email,
        },
    );
    
    return $profile->next;
}

=head2 digest_password(C<$password>)

Digests the password using SHA1 with a key (salt).

=cut

sub digest_password {
    my ( $self, $password ) = @_;
    
    my $digest = Digest->new($self->{'hash_type'});

    $digest->add($self->{'salt'})
        if $self->{'salt'};

    $digest->add($password);

    return $digest->b64digest;
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


# Accessor for the model object for the profile database table
__PACKAGE__->mk_accessors(qw/_model/);


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
