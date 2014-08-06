package Stormpath::Client;
use Carp;
use Stormpath::Client::UserAgentProxy;
use Moo;

extends qw(REST::Client);

sub FOREIGNBUILDARGS {
    my $class = shift;
    return @_;
}

sub BUILD {

  if($_[0]->api_key_file_location() && -e $_[0]->api_key_file_location()) {
    my $c = Config::YAML->new( config => $_[0]->api_key_file_location() );
    $_[0]->id($c->get_id());
    $_[0]->secret($c->get_key());
  } elsif(!defined($_[0]->id()) || !defined($_[0]->secret())) {
        Carp::confess("if api file not provided id and secret must be");
  }

}

has 'id' => ( 
    is => 'rw'
);

has 'secret' => ( 
    is => 'rw'
);

has 'method' => ( 
    is => 'ro',
    default => sub {
        return 'SAuthc1';
    }
);

has 'api_key_file_location' => ( 
    is => 'rw',
);

has 'useragent' => (
    is => 'lazy'
);

sub _build_useragent {
    my $ua_proxy = Stormpath::Client::UserAgentProxy->new(
    id => $self->id(),
    secret => $self->secret(),
    method => $self->method()
    );
    $ua_proxy->ua()->agent("REST::Client/1.0");
    return $ua_proxy;
}

# proxy this so it does signing 
sub _buildUseragent {
    my $self = shift;
    return $self->useragent();
}

1;
