use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Backend::ForecastRetrieval' }

#ok( request('/backend/forecastretrieval')->is_success, 'Request should succeed' );


