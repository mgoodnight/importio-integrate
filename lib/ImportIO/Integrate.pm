package ImportIO::Integrate;

# ABSTRACT: Module to give an interface to the integration capabilities of import.io

use strict;
use warnings;

use Moo;
use Furl;
use IO::Socket::SSL;
use URI::Encode;
use Try::Tiny;
use JSON qw/decode_json/;

has api_key => (
    is => 'ro',
    required => 1
);

has extractor_id => (
    is => 'rw',
    required => 1
);

has target_url => (
    is => 'rw'
);

has ua => (
    is      => 'ro',
    builder => sub {
        return Furl->new(
            timeout  => 300,
            ssl_opts => {
                SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_PEER(),
            }
        );
    }
);

has ua_headers => (
    is      => 'rw',
    builder => sub {
        return [
            'Accept-Encoding' => 'gzip',
        ];
    }
);

has last_query_response => (
    is => 'rwp'
);

has last_query_error => (
    is => 'rwp'
);

sub live_extractor_query {
    my $self = shift;

    unless ($self->target_url) { warn "No URL defined.  Live query will likely fail..." };

    my $query_url = $self->_generate_live_url;
    my $content = $self->_query($query_url);

    my $deserialized_content;
    try {
        $deserialized_content = decode_json($content);
    }
    catch {
        warn "There was an issue deserializing response content.";
    };

    return $deserialized_content;
}

sub last_run_csv_query {
    my $self = shift;
    my $query_url = $self->_generate_csv_url;
    my $content = $self->_query($query_url, $self->ua_headers);

    return $content;	
}

sub last_run_json_query {
    my $self = shift;
    my $query_url = $self->_generate_json_url;
    my $content = $self->_query($query_url, $self->ua_headers);

    my $deserialized_content;
    try {
        $deserialized_content = decode_json($content);
    }
    catch {
        warn "There was an issue deserializing response content.";
    };

    return $deserialized_content;
}

sub get_google_sheets_formula {
    my $self = shift;
    my $query_url = $self->_generate_csv_url;
    my $formula = '=IMPORTDATA("' . $query_url . '")';

    return $formula;
}

sub last_live_query_info {
    my $self = shift;
    my $query_url = $self->generate_rss_url;
    my $content = $self->_query($query_url);
	
    return $content;
}

sub generate_rss_url {
    my $self = shift;
    my $url = 'https://rss.import.io/extractor/' . 
              $self->extractor_id .
              '/runs?_apikey=' .
              $self->api_key;
	
    return $url;
}

sub _generate_live_url {
    my $self = shift;
    my $uri_encoder = URI::Encode->new();

    my $url = 'https://extraction.import.io/query/extractor/' .
              $self->extractor_id .
              '?_apikey=' .
              $self->api_key .
              '&url=' .
              $uri_encoder->encode( $self->target_url );
              
    return $url;
}

sub _generate_csv_url {
    my $self = shift;
    my $url = 'https://data.import.io/extractor/' .
              $self->extractor_id .
              '/csv/latest?_apikey=' .
              $self->api_key;

    return $url;
}

sub _generate_json_url {
    my $self = shift;
    my $url = 'https://data.import.io/extractor/' .
              $self->extractor_id .
              '/json/latest?_apikey=' .
              $self->api_key;

    return $url;
}

sub _query {
    my ($self, $extractor_url, $headers) = @_;

    my $response = $self->ua->get($extractor_url, $headers);
    $self->_set_last_query_response($response);
	
    my $content_decoded = $response->decoded_content;
    $self->_set_last_query_error($content_decoded) if !$response->is_success;
	
    return $content_decoded;
}

1;
