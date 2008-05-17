use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Logout' }

#ok( request('/logout')->is_success, 'Request should succeed' );


