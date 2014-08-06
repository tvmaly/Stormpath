package Stormpath::Resources::Resource;
use 5.14;
use strict;
use Moo::Role;

has base_url => (
    is       => 'ro',
    default => sub { return 'https://api.stormpath.com/v1'; }
);

has sub_path => (
    is       => 'rw',
    required => 1
);

has id => (
    is       => 'rw',
    trigger => sub {
        $_[0]->changed()->{id} = 1;
        $_[0]->dirty(1);
    }
);

has key => (
    is       => 'rw',
    trigger => sub {
        $_[0]->changed()->{key} = 1;
        $_[0]->dirty(1);
    }
);

has name => (
    is       => 'rw',
    trigger => sub {
        $_[0]->changed()->{name} = 1;
        $_[0]->dirty(1);
    }
);

has changed => (
    is => 'rw',
    default => sub { return {}; }
);

has dirty => (
    is       => 'rw'
);

has href => (
    is       => 'lazy'
);

sub _build_href {

    my $self = shift;

    confess("ERROR: id for resource type " . $self->sub_path() . " not set, cannot build the href from parts") if !defined($self->id());

    return join('/',($self->base_url(),$self->sub_path(),$self->id());

}

1;
