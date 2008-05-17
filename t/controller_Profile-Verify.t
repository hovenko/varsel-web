use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Profile::Verify' }

#ok( request('/profile/verify')->is_success, 'Request should succeed' );


