use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::User' }

#ok( request('/user')->is_success, 'Request should succeed' );


