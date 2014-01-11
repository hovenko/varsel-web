package Varsel::Model::Profile::Email::Password;

# FIXME make a generic assemble_email method in Varsel::Model::Profile::Email

use strict;
use warnings;
use utf8;

use Email::MIME::Creator;
use Encode qw/encode/;
use Params::Validate;

use base qw/Catalyst::Model Class::Accessor::Fast/;

=head1 NAME

Varsel::Model::Profile::Email::Password - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 from

The sender address of lost password emails.

=head2 template

The template to use for the body of the email.

=head2 view

The view used to render the body of the email.

=head2 subject

The subject that is sent in the email.

=cut

__PACKAGE__->config(
    'from'              => 'Weather report <root@localhost>',
    'template'          => 'email/password/lost.tt2',
    'view'              => 'TTEmail',
    'subject'           => 'Request a new password',
);

=head1 METHODS

=head2 lost_password_email

This method prepares the lost password email.

It returns a HASHREF with the body, subject and other headers of the email.

=cut

sub lost_password_email {
    my $self = shift;
    
    my %data = validate(@_,{
        'email'   => {
            'type'      => Params::Validate::SCALAR,
        },
    });
    
    my $email   = $data{'email'};
    my $from    = $self->{'from'};
    my $subject = $self->{'subject'};
    my $body    = $self->body;
    
    utf8::decode($subject);
    utf8::decode($email);
    utf8::decode($from);
    utf8::decode($body);
    
    $subject    = encode('MIME-Header', $subject);
    $email      = encode('MIME-Header', $email);
    $from       = encode('MIME-Header', $from);
    
    my @headers = (
        'Subject'   => $subject,
        'To'        => $email,
        'From'      => $from,
    );
    
    my @parts   = (
        Email::MIME->create(
            'attributes'    => {
                'content_type'  => 'text/plain',
                'charset'       => 'utf-8',
            },
            'body'          => $body,
        ),
    );
    
    my %email = (
        'header'    => \@headers,
        'parts'     => \@parts,
    );
    
    return \%email;
}

=head2 body

Accessor for the body content of the email.

=cut

__PACKAGE__->mk_accessors(qw/body/);

=head2 ACCEPT_CONTEXT

Assembles the body content of the email by using the configured view.

Returns C<$self>.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;
    
    my $body = $c->forward(
        $c->view( $self->{'view'} ), 'render',
        [$self->{'template'}]
    );
    
    if (UNIVERSAL::isa($body, 'Template::Exception')) {
        my $error = qq/Failed to generate email body for the verification email: $body/;
        $c->log->error($error);
        return;
    }
    
    $self->body($body);
    
    return $self;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
