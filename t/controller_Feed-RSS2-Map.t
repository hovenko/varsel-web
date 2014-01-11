use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Feed::RSS2::Map' }

ok( request('/feed/rss2/map')->is_success, 'Request should succeed' );


