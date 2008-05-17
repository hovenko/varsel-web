package Varsel::Controller::Backend::TemplateTester;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Varsel::Controller::Backend::TemplateTester - Catalyst Controller

=head1 DESCRIPTION

This controller is used purly for testing templates in this application.
You access this controller by entering the URL to the root action of this
controller and pass on the template name as parameter.

=head1 METHODS

=head2 tester(C<$template>)

This action is hooked on the root of this controller and will test a template
given as parameter.

If the template you want to test is inside a folder (beneath root/src/) you
separate directories with a dot, C<.>. The suffix C<.tt2> will be appended
automatically.

For example, to test the C<< register/profile.tt2 >> template enter this:
  C<register.profile>

=cut

sub tester : Path Args(1) {
    my ( $self, $c, $template ) = @_;

    $template =~ s{\.}{/}xms;
    $c->stash->{'template'} = "$template.tt2";
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}


=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
