use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Varsel' }
BEGIN { use_ok 'Varsel::Controller::Feed::RSS2::Stored' }

ok( request('/feed/rss2/stored')->is_success, 'Request should succeed' );


