use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Feed::Register' }

ok( request('/feed/register')->is_success, 'Request should succeed' );


