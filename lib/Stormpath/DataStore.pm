package Stormpath::DataStore;
use strict;
use Carp;
use version; 
$VERSION = qv('1.0.0');

use Cache::Memory;
use Moo;
use namespace::clean;

use constant CACHE_REGIONS => [ 
        'accounts',
        'accountStoreMappings',
        'applications',
        'directories',
        'groups',
        'groupMemberships',
        'tenants'
];

sub _get_cache {

   my ($self,$href) = @_;

   my $region = $self->_get_cache_region($href);

   return if !defined($region);

   if($self->cache_manager()->exists($region)) {
        return $self->cache_manager()->get($region);
   }

   return;
}


sub _get_cache_region {

   my ($self,$href) = @_;

   return if $href !~ /\//;

   my $region = (split /\//,$href)[-2];

   return $region;

}

sub _cache_get {

   my ($self,$href) = @_;

   return $self->_get_cache($href);

}

sub _cache_put {

   my ($self,$href,$data,$new) = @_;

   return if ref($data) ne 'HASH';

   my $resource_data = {};

   my $v2 = {};

   foreach my $name (keys %$data) {

        my $value = $data->{$name};

            if($self->_data_href($value)) {

                $v2->{'href'} = $self->_data_href($value);

                if($self->_data_items($value)) {

                    $v2->{'items'} = [];

                    foreach my $item (keys %{$self->_data_items($value)}) {

                        if($self->_data_href($item)) {

                            $self->_cache_put($self->_data_href($item), $item);

                            push @{$v2->{'items'}},
                                { 'href' => $self_data_href($item) };

                        }
                    }

                } else {
                    if(scalar(keys %$value) > 1) {
                        $self->_cache_put($self->_data_href($value),$value);
                    }
                }
                $self->_cache_put($self->_data_href($data->{$name}),
            } else {

                $v2 = $value;

                $resource_data->{$name} = $v2;


            }

    }

    $self->_get_cache($href)->{$href} = $resource_data;
}

sub _get_cache {

   my ($self,$href) = @_;

   my $region = $self->_get_cache_region($href);

   return if !defined($region);

   if($self->cache_manager()->exists($region)) {
        return $self->cache_manager()->get($region);
   }

   return;
}


sub _cache_del {

    my ($self,$href) = @_;
    
    delete($self->_get_cache($href)->{$href});

}

sub get_resource {

    my ($self,$href,$params) = @_;

    my $data = $self->_get_cache($href)->{$href};

    if(!defined($data)) {

        $data = $self->executor()->GET($href, $params);

        $self->_cache_put($href,$data);

    } else {

        return $data;

    }

}

sub create_resource {

    my ($self,$href,$data,$params) = @_;

    my $response = $self->executor()->POST($href,$data,$params);

    # TODO handle errors
    
    return $data;


}

sub update_resource {

    my ($self,$href,$data) = @_;

    # TODO

}

sub delete_resource {

    my ($self,$href) = @_;

    # TODO
    
}

sub _data_href {

 my $self = shift;

 my $data = shift;

 if(ref($data) eq 'HASH' && exists($data->{'href'})) {
    return $data->{'href'};
 }

 return;

}

sub _data_items {

 my $self = shift;

 my $data = shift;

 if(ref($data) eq 'HASH' && exists($data->{'items'})) {
    return $data->{'items'};
 }

 return;

}

has 'executor' => ( 
    is => 'ro',
    required => 1 
);

has cache_options => (
    is       => 'rw',
    required => 1,
    builder => sub { return {}; }
);

has cache_manager => (
    is       => 'ro'
    default => sub { return Cache::Memory->new( namespace => 'Stormpath',
                                default_expires => '24 hour' );
    }
);

sub BUILD {

    my $self = shift;

    my $cache_options = $self->cache_options();

    my $cache = $self->cache_manager();

    foreach my $region (@{CACHE_REGIONS}) {

        my $regional_cache_options = exists($cache_options->{$region}) ? $cache_options->{$region} : {} ;

            $cache->set($region,$regional_cache_options);

        }
    }

    return;

}


1;
