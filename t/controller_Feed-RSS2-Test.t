use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Feed::RSS2::Test' }

ok( request('/feed/rss2/test')->is_success, 'Request should succeed' );


