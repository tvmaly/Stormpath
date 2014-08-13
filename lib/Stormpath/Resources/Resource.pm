package Stormpath::Resources::Resource;
use 5.14;
use strict;
use Carp;
use Moo::Role;
use String::CamelCase qw(camelize);

has client => (
    is       => 'ro',
    required => 1
);

has base_url => (
    is       => 'ro',
    default => sub { return 'https://api.stormpath.com/v1'; }
);

has sub_path => (
    is       => 'rw',
    required => 1
);

has writable_attrs => (
    is       => 'rw',
    required => 1
);

has autosaves => (
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

sub is_new {
    return !defined($_[0]->href());
}

sub save {
   
    if($self->is_new()) {
        # should we use Throwable::Factory
        # or just Carp for less dependencies?
        Carp::confess("Can't save new resources, use create instead");
    }

    $self->client()->update_resource($self->href(),$self->_get_properties());

}

sub non_attributes {
    return {'dirty' => 1,'changed' => 1,'base_url' => 1,'sub_path' => 1};
}

sub dict_items {

    my $non_attributes = $_[0]->non_attributes();

    return grep { !exists($non_attributes->{$_}) } keys(%{
        'Moo'->_constructor_maker_for(ref($_[0]))->all_attribute_specs
    })
}

sub _get_properties {
        my $data = {}

        my $writable_attrs = $self->writable_attrs();
        foreach my $k (grep { exists($writable_attrs->{$_}) } $self->dict_items()) {
            $data->{camelize($k)} = $self->_sanitize_property($self->$k());

        }

        #for k, v in self.__dict__.items():
            #if k in self.writable_attrs:
                #data[self.to_camel_case(k)] = self._sanitize_property(v)

        return $data

}

sub _sanitize_property {

  # TODO convert from python
    def _sanitize_property(value):
        if isinstance(value, Resource):
            if value.href:
                return {'href': value.href}
            else:
                return value._get_properties()
        elif isinstance(value, dict):
            return {Resource.to_camel_case(k):Resource._sanitize_property(v)
                for k, v in value.items()}
        else:
            return value
}

sub construct_href {

    my $self = shift;

    confess("ERROR: id for resource type " . $self->sub_path() . " not set, cannot build the href from parts") if !defined($self->id());

    return join('/',($self->base_url(),$self->sub_path(),$self->id());

}

1;
