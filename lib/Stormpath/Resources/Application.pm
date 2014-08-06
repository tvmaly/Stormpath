package Stormpath::Resources::Application;
use strict;
use Carp;
use version; 
$VERSION = qv('1.0.0');

use Moo;
use namespace::clean;

with('Stormpath::Resources::Resource');

has '+sub_path' => (
    default => sub { 'applications' },
);

has description => (
    is       => 'rw'
);

has status => (
    is       => 'rw'
);

has tenant => (
    is       => 'rw'
);

has password_reset_tokens => (
    is       => 'rw'
);

has login_attempts => (
    is       => 'rw'
);

has accounts => (
    is       => 'rw'
);

has groups => (
    is       => 'rw'
);

has account_store_mappings => (
    is       => 'rw'
);

has default_account_store_mappings => (
    is       => 'rw'
);

has default_group_store_mappings => (
    is       => 'rw'
);

1;
