use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Varsel::Model::GoogleMaps' }

Varsel::Model::GoogleMaps->config(
    'url'   => 'http://maps.google.com/maps?file=api&v=2&key=%s',
    'key'   => 'dummy',
);

my $maps = Varsel::Model::GoogleMaps->new();
my $google_map_point = "(59.589106172938294, 10.213165283203125)";


is_deeply(
    $maps->extract_geo($google_map_point),
    {
        'latitude'  => '59.589106172938294',
        'longitude' => '10.213165283203125',
    },
    'Parsing a Google Maps point'
);

is(
    $maps->javascript_url(),
    'http://maps.google.com/maps?file=api&v=2&key=dummy',
    'Assembling the javascript URL with the API key'
);
