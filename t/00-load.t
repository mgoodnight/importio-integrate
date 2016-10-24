#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use Furl;
use ImportIO::Integrate;

my $api_key = $ENV{IMPORTIO_API_KEY};
my $extractor_id = $ENV{IMPORTIO_EXTRACTOR_ID};
my $target_url = $ENV{IMPORTIO_TARGET_URL};

use_ok('ImportIO::Integrate');
require_ok('ImportIO::Integrate');
dies_ok { ImportIO::Integrate->new() } "Dies on missing required attributes.";

my $importio = ImportIO::Integrate->new(api_key => $api_key, extractor_id => $extractor_id, target_url => $target_url);
isa_ok($importio, 'ImportIO::Integrate');

foreach my $method ( map { chomp $_; $_; } <DATA> ) {
    can_ok('ImportIO::Integrate', $method);
}

SKIP: {
    skip "Need API key.", 1 unless ($api_key);
    ok defined($importio->api_key), "api_key is defined (required parameter).";
}

SKIP: {
    skip "Need extractor ID.", 1 unless ($extractor_id);
    ok defined($importio->extractor_id), "extractor_id is defined (required parameter).";
}

ok defined($importio->ua), "We built our UserAgent.";
isa_ok($importio->ua, 'Furl');
ok defined($importio->ua_headers), "Our HTTP headers are defined.";
ok ref($importio->ua_headers) eq 'ARRAY', "We have our list of necessary HTTP headers for our UserAgent.";

dies_ok { $importio->api_key("new_api_key") } "Dies when trying to modify a read-only attribute (api_key).";
dies_ok { $importio->ua(Furl->new()) } "Dies when trying to modify a read-only attribute (ua).";

done_testing();

__DATA__
api_key
extractor_id
target_url
ua
ua_headers
last_query_response
last_query_error
live_extractor_query
last_run_csv_query
last_run_json_query
get_google_sheets_formula
last_live_query_info
generate_rss_url
_generate_live_url
_generate_csv_url
_generate_json_url
_query
