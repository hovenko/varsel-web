package Varsel::View::Email;

use strict;

use Data::Dumper;

use base 'Catalyst::View::Email';

=head1 NAME

Varsel::View::Email - Email View for Varsel

=head1 DESCRIPTION

View for sending email from Varsel. 

=head1 CONFIGURATION

=head2 stash_key

The parameter in the stash used for email data.

=head2 default

Default settings for email sending.

=head3 content_type

The content type of email parts. Defaults to C<text/plain>.

=head3 charset

The charset used in email parts. Defaults to C<utf-8>.

=head2 sender

Configuration for the mailer.

=head3 mailer

The name of the mailer to use for sending out emails. Defaults to Sendmail.

Examples: C<SMTP> and C<Sendmail>.

=head3 mailer_args

The arguments passed directly on to the mailer. For SMTP, C<Host>, C<Port> and
<ssl> can be good configurable parameters.

=cut

__PACKAGE__->config(
    'stash_key' => 'email',
    'default'   => {
        'content_type'  => 'multipart/alternative',
        'charset'       => 'utf-8',
    },
    'sender'    => {
        'mailer'        => 'Sendmail',
    },
);


=head1 METHODS

=head2 process

=cut

sub process {
    my ( $self, $c ) = @_;

    if ($c->debug) {
        $c->log->debug("We are in debug mode and don't send emails.");
        $c->log->debug("Here is the content of the email:");
        $c->log->debug(Dumper $c->stash->{'email'});
    }
    else {
        return $self->NEXT::process($c);
    }
}

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 SEE ALSO

L<Varsel>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
