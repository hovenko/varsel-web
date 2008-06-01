use strict;
use warnings;

use Data::Dumper;

use Test::More tests => 10;

BEGIN { use_ok 'Varsel::Model::Javascripts' }

Varsel::Model::Javascripts->config(
    'myscript'      => {
        'uri'           => '/static/js/myscript.js',
        'deps'          => ['other-script'],
        'params'        => {
            'apikey'        => 'very-secret',
        },
    },
    'other-script'  => {
        'uri'           => 'http://example.com/other-script.js',
    }
);

my $model   = Varsel::Model::Javascripts->new();
my $js      = $model->ACCEPT_CONTEXT(undef);

diag('Loading "myscript" to invoke dependency injection on "other-script".');

$js->add_script('myscript');

# This array is ordered by dependencies
my @scripts = @{ $js->scripts };

isa_ok(
    \@scripts,
    'ARRAY',
    'Loaded scripts is an array'
);

is(
    scalar @scripts,
    2,
    'Two scripts are loaded'
);

is(
    $scripts[0]->{'name'},
    'other-script',
    'The first script to load is other-script',
);

is(
    $scripts[1]->{'name'},
    'myscript',
    'The second script to load is myscript'
);

is(
    $scripts[1]->{'url'},
    '/static/js/myscript.js?apikey=very-secret',
    'Assemble the URI with the parameters'
);

is(
    $scripts[0]->{'url'},
    $scripts[0]->{'uri'},
    'The url and uri is the same when not adding params'
);

is(
    $scripts[0]->{'url'},
    'http://example.com/other-script.js',
    'The url is the same as the uri from configuration'
);



diag('Loading "other-script", to avoid dependency invocation');

$js         = $model->ACCEPT_CONTEXT(undef);
$js->add_script(qw/other-script/);
@scripts    = @{ $js->scripts };

is(
    scalar @scripts,
    1,
    'Only the single added script is loaded'
);

is(
    $scripts[0]->{'url'},
    'http://example.com/other-script.js',
    'The url is the same as the uri from configuration'
);

