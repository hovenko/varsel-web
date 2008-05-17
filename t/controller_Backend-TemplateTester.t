use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Backend::TemplateTester' }

ok( request('/backend/templatetester')->is_success, 'Request should succeed' );


