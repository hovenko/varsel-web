package Varsel::Model::ForecastFeed;

use strict;
use warnings;

use base qw/
    Catalyst::Model
    Class::Accessor::Fast
/;

=head1 NAME

Varsel::Model::ForecastFeed - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 dbmodel

Name of the model representing the B<forecast_notice> database table.
Do not include the C<Varsel::Model> prefix in the package name.

Defaults to C<YRDB::ForecastNotice>.

=cut

__PACKAGE__->config(
    'dbmodel'       => 'YRDB::ForecastFeed',
);


=head1 METHODS

=head2 create(B<\%feed>)

This method inserts a new forecast feed into the database table
B<forecast_feed>.

It returns the forecast feed object after insert.

=cut

sub create {
    my ( $self, $feed ) = @_;

    $feed   = $self->_model->create($feed);
    $feed->insert;

    return $feed;
}

=head2 find_by_id(B<$id>)

Returns the forecast feed with a given ID, if any.

=cut

sub find_by_id {
    my ( $self, $id ) = @_;

    my $feeds = $self->_model->search(
        {
            'id'    => $id,
        }
    );

    return $feeds->first;
}

=head2 find_by_user(C<$profile>)

This finds all feeds that a user has registered.

Parameter C<$profile> can be either a DBIC entity reference or a profile ID.

=cut

sub find_by_user {
    my ( $self, $profile ) = @_;

    my $uid     = ref $profile ? $profile->id : $profile;
    my $now     = DateTime->now('time_zone' => 'local');

    my $feeds = $self->_model->search(
        {
            'profile'       => $uid,
            'hidden'        => 0,
        }
    );

    return $feeds->all;
}

=head2 update(B<$feed>)

This updates the feed in the database.

=cut

sub update {
    my ( $self, $feed ) = @_;
    $feed->update;
}

=head2 ACCEPT_CONTEXT

This loads the database model for forecast feeds.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    my $model = $c->model($self->{'dbmodel'});
    $self->_model($model);
    
    return $self;
}


# Accessor for the model object for the database table
__PACKAGE__->mk_accessors(qw/_model/);


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
