package Stormpath::Client;
use Carp;
use HTTP::Request;
use Date::Format qw(time2str);
use UUID::Tiny ':std';
use Encode qw(encode);
use Digest::SHA qw(sha256_hex hmac_sha256_hex);
use Config::YAML;
use MIME::Base64;
use Moo;

extends qw(REST::Client);

use constant HOST_HEADER => 'Host';
use constant AUTHORIZATION_HEADER => 'Authorization';
use constant STORMPATH_DATE_HEADER => 'X-Stormpath-Date';
use constant ID_TERMINATOR => 'sauthc1_request';
use constant ALGORITHM => 'HMAC-SHA-256';
use constant AUTHENTICATION_SCHEME => 'SAuthc1';
use constant SAUTHC1_ID => 'sauthc1Id';
use constant SAUTHC1_SIGNED_HEADERS => 'sauthc1SignedHeaders';
use constant SAUTHC1_SIGNATURE => 'sauthc1Signature';
use constant DATE_FORMAT => '%Y%m%d';
use constant TIMESTAMP_FORMAT => '%Y%m%dT%H%M%SZ';
use constant NL => '\n';

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

# setup request to do basic authorization
sub basic {

    my $self = shift;

    my $http_request = shift;

    $http_request->authorization_basic($self->id(), $self->secret());

    return $http_request;

}

sub http_request {

 my $self = shift;

 my $http_request = shift;

 return $self->request(
    $http_request->method(),
    $http_request->uri(),
    $http_request->content(),
    $self->split_headers($http_request->headers()) 
 );

}

# use Stormpath algorithm to sign request
# TODO test that my implementation works
sub sign_request {
 
    my $self = shift;

    my $http_request = shift;

    my $time = time();

    my $time_stamp = time2str(TIMESTAMP_FORMAT,$time);

    my $date_stamp =  time2str(DATE_FORMAT,$time);

    my $nonce = create_uuid_as_string(UUID_V4);

    my $parsed_url = $http_request->uri;

    my $headers = $self->split_headers($http_request->headers());

    my $host_header = $parsed_url->host();

    if(!$self->_is_default_port($parsed_url)) {

        $host_header = $parsed_url->netloc();

    }

    $headers->{HOST_HEADER} = $host_header;
    $headers->{STORMPATH_DATE_HEADER} = $time_stamp;

    my $canonical_resource_path;

    if($parsed_url->path()) {
            $canonical_resource_path = $parsed_url->epath(); 
    } else {
            $canonical_resource_path = '/';
    }

    my $canonical_query_string;

    if($parsed_url->query()) {
            $canonical_query_string = $parsed_url->equery(); 
    }

    my $method = $http_request->method();

    my $auth_headers = { %$headers };

    if(exists($auth_headers->{'Content-Length'})) {

        delete $auth_headers->{'Content-Length'}

    }

    my $canonical_headers_string = ''

    foreach $key (sort keys %$auth_headers) {
            
            $canonical_headers_string .= sprintf("%s:%s%s",(lc($key),$value,NL));

    }

    my $signed_headers_string = join(';',map { uc($_); } sort keys %$auth_headers);
    
    my $body = $http_request->decoded_content();

    $body = '' if !defined($body);

    my $request_payload_hash_hex =sha256_hex($body);
    
    my $canonical_request = sprintf('%s%s%s%s%s%s%s%s%s%s%s',( 
            $method, NL, $canonical_resource_path, NL, $canonical_query_string,
            NL, $canonical_headers_string, NL, $signed_headers_string,
            NL, $request_payload_hash_hex);

    my $id = sprintf('%s/%s/%s/%s',($self->id(),$date_stamp,$nonce,ID_TERMINATOR) 

    my $canonical_request_hash_hex = sha256_hex($canonical_request);

    my $string_to_sign = sprintf('%s%s%s%s%s%s%s',(ALGORITHM, NL, $time_stamp, NL, $id, NL, $canonical_request_hash_hex));

    my $k_secret = sprintf('%s%s',(AUTHENTICATION_SCHEME, $self->secret()));

    my $k_date = hmac_sha256_hex($date_stamp, $k_secret);

    my $k_nonce = hmac_sha256_hex($nonce, $k_date);

    my $k_signing = hmac_sha256_hex(ID_TERMINATOR, $k_nonce);

    my $signature = hmac_sha256_hex($string_to_sign, $k_signing);

    my $authorization_header = join(', ',(
        sprintf('%s %s=%s',(AUTHENTICATION_SCHEME, SAUTHC1_ID, $id )),
        sprintf('%s=%s',(SAUTHC1_SIGNED_HEADERS, $signed_headers_string )),
        sprintf('%s=%s',SAUTHC1_SIGNATURE, $signature )));

    )

    $headers->{AUTHORIZATION_HEADER} = $authorization_header;

    $http_request->{_headers}->clear;

    foreach my $header_key (keys %$headers) {
        $http_request->{_headers}->header($header_key, $headers->{$header_key});
    }

    return $http_request;

}

sub _is_default_port {

    my $self = shift;

    my $parsed_url = shift;

    my $port = $parsed_url->port;

    my $scheme = $parsed_url->scheme;

    return not $port 
        or ($port == 80 and $scheme eq 'http') 
        or ($port == 443 and $scheme eq 'https');

}

sub split_headers {

    my $self = shift;

    my $headers = shift;

    my $split_headers = {};

    return $split_headers if !defined($headers);

    my @key_value_headers = split /\n/,$headers->as_string();


    foreach my $kv_header (@key_value_headers) {

        my ($key,$value) = split ': ',$kv_header;

        $split_headers->{$key} = $value;

    }

    return $split_headers;

}

1;
