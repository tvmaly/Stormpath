package Stormpath::Resources::Tenant;
use strict;
use Carp;
use version; 
$VERSION = qv('1.0.0');

use Moo;
use namespace::clean;

with('Stormpath::Resources::Resource');

has '+sub_path' => (
    default => sub { 'tenants' },
);


has applications => (
    is       => 'rw',
    required => 1
);


has directories => (
    is       => 'rw',
    required => 1
);

1;
