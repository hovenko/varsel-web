use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Varsel::Model::Profile' }

Varsel::Model::Profile->config(
    'salt'  => 'secret',
);

my $profile = Varsel::Model::Profile->new();

my $password        = 'password';
my $passworddigest  = '7b0Yh+dy4TwlH2iKXxDB/7tnlg0';

is(
    $profile->digest_password($password),
    $passworddigest,
    'Digesting the password'
);

