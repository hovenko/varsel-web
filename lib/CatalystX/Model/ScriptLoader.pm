package CatalystX::Model::ScriptLoader;

use strict;
use warnings;

use HTML::ScriptLoader;

use base qw/
    Catalyst::Model
    Class::Accessor::Fast
/;


=head1 NAME

CatalystX::Model::ScriptLoader - Class for loading scripts on a web page

=head1 SYNOPSIS

    # 
    # This example shows how to load Javascripts using this model.
    #
    
    # In your model
    package MyApp::Model::Javascripts;
    use base 'CatalystX::Model::ScriptLoader';
    
    # In your controller
    sub index : Private {
        my ( $self, $c ) = @_;
        $c->model('Javascripts')->add_script('myscript');
    }

    sub end : ActionClass('RenderView') {
        my ( $self, $c ) = @_;
        $c->stash->{'javascripts'} = $c->model('Javascripts')->scripts;
    }

    # In your HTML template
    <head>
        [% FOREACH js IN javascripts %]
        <script type="text/javascript" src="[% js.url %]" />
        [% END %]
        <!-- ... -->
    </head>
    
    # In your configuration (YAML)
    Model::Javascripts:
        myscript:
            uri:    /static/js/myscript.js
            deps:
                -   other-script
            params:
                apikey: very-secret
        other-script:
            uri:    http://example.com/other-script.js

    # or, in your model configuration (Perl)
    __PACKAGE__->config(
        'myscript'      => {
            'uri'           => '/static/js/myscript.js',
            'deps'          => [qw/other-script/],
            'params'        => {
                'apikey'        => 'very-secret',
            },
        },
        'other-script'  => {
            'uri'           => 'http://example.com/other-script.js',
        },
    );


=head1 DESCRIPTION

This class utilizes L<HTML::ScriptLoader> to provide easy access for loading
scripts on a web page with dependency support.

=head1 METHODS

=head2 ACCEPT_CONTEXT

Returns a reference to L<HTML::ScriptLoader> with the scripts that were
set up in configuration.

=cut

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;

    my $scriptloader    = HTML::ScriptLoader->new($self);

    return $scriptloader;
}

=head1 SEE ALSO

L<HTML::ScriptLoader>

=head1 AUTHOR

Knut-Olav Hoven,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the terms of GPL version 2.

=cut

1;
