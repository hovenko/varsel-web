package Varsel::Model::Forecast::Email;

use strict;
use warnings;
use utf8;

use Email::MIME::Creator;
use Encode qw/encode/;
use Params::Validate;

use base qw/Catalyst::Model Class::Accessor::Fast/;

=head1 NAME

Varsel::Model::Forecast::Email - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 CONFIGURATION

=head2 from

The sender address of verification emails.

=head2 template

The template to use for the body of the email.

This has no default and must be supplied in configuration file or given as
parameter to L</ACCEPT_CONTEXT>. This is required.

=head2 template_html

Much like L</template>, but will render an HTML body part.

This has no default and must be supplied in configuration file or given as
parameter to L</ACCEPT_CONTEXT> if wanted. This is optional.

=head2 view

The view used to render the body of the email.

=head2 subject

The subject that is sent in the email.

=cut

__PACKAGE__->config(
    'from'              => 'Weather report <root@localhost>',
    'template'          => undef,
    'template_html'     => undef,
    'view'              => 'TTEmail',
    'subject'           => 'Welcome to weather report home to you',
);

=head1 METHODS

=head2 prepare_email

This method prepares the email body and headers. It will also create a HTML
body part if an HTML template was given.

It returns a HASHREF with the body, subject and other headers of the email.

=cut

sub prepare_email {
    my $self = shift;
    
    my %data = validate(@_,{
        'email'   => {
            'type'      => Params::Validate::SCALAR,
        },
    });
    
    my $email       = $data{'email'};
    my $from        = $self->{'from'};
    my $subject     = $self->{'subject'};
    my $body        = $self->body;
    my $htmlbody    = $self->htmlbody;
    
    utf8::decode($subject);
    utf8::decode($email);
    utf8::decode($from);
    utf8::decode($body);
    utf8::decode($htmlbody);
    
    $subject    = encode('MIME-Header', $subject);
    $email      = encode('MIME-Header', $email);
    $from       = encode('MIME-Header', $from);
    
    my @headers = (
        'Subject'   => $subject,
        'To'        => $email,
        'From'      => $from,
    );
    
    my @parts   = ();
    
    push @parts, Email::MIME->create(
        'attributes'    => {
            'content_type'  => 'text/html',
            'charset'       => 'utf-8',
        },
        'body'          => $htmlbody,
    ) if $htmlbody;
    
    push @parts, (
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
    
    # Set the content type as multipart if we have HTML body
    $email{'content_type'}  = 'multipart/alternative'
        if $htmlbody;
    
    return \%email;
}

=head2 body

Accessor for the body content of the email.

=head2 htmlbody

Accessor for the body content of the email in HTML format. It will only be
used if the C<template_html> configuration parameter is set.

=cut

__PACKAGE__->mk_accessors(qw/body htmlbody/);

=head2 ACCEPT_CONTEXT

Assembles the body content of the email by using the configured view.

Returns C<$self>.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c, $args ) = @_;
    
    $args               ||= {};
    @$self{keys %$args} = values %$args;
    
    Catalyst::Exception->throw("Missing template to render for email body")
        unless $self->{'template'};
    
    my $body = $c->forward(
        $c->view( $self->{'view'} ), 'render',
        [$self->{'template'}]
    );
    
    if (UNIVERSAL::isa($body, 'Template::Exception')) {
        my $error = qq/Failed to generate email body for the verification email: $body/;
        $c->log->error($error);
        
        Catalyst::Exception->throw($error);
        #return;
    }
    
    $self->body($body);
    
    my $htmlbody    = $c->forward(
        $c->view( $self->{'view'} ), 'render',
        [$self->{'template_html'}]
    ) if $self->{'template_html'};
    
    $self->htmlbody($htmlbody);
    
    return $self;
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
