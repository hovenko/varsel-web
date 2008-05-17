use strict;
use warnings;
use Test::More tests => 6;

BEGIN {
    use_ok 'Varsel::Model::YRDB';
}

BEGIN { use_ok 'Varsel' }
BEGIN { use_ok 'Varsel::Model::Profile::Register' }



my $context = Varsel->new();

my $register = $context->model('Profile::Register');

isa_ok(
    $register,
    'Varsel::Model::Profile::Register',
    'Model instance created'
);

is(
    length $register->generate_code(),
    10,
    'Default code is 10 characters long'
);

is(
    length $register->generate_code(20),
    20,
    'Code with a specified length'
);

#my %register = (
#    'id'    => 123,
#    'email' => 'email@example.com',
#);
#
#ok(
#    my $registered = $register->create(%register),
#    'Creating registration data'
#);
#
#ok(
#    $registered->{'code'},
#    'The code gets set during create.'
#);

