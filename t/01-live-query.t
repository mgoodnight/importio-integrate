#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use ImportIO::Integrate;

my $api_key = $ENV{IMPORTIO_API_KEY};
my $extractor_id = $ENV{IMPORTIO_EXTRACTOR_ID};
my $target_url = $ENV{IMPORTIO_TARGET_URL};

my $importio = ImportIO::Integrate->new(api_key => $api_key, extractor_id => $extractor_id, target_url => $target_url);
my $importio_apikey_fail = ImportIO::Integrate->new(api_key => 'acb1234_bad', extractor_id => $extractor_id, target_url => $target_url);
isa_ok($importio, 'ImportIO::Integrate');
isa_ok($importio_apikey_fail, 'ImportIO::Integrate');

my $live_scrape_result = $importio->live_extractor_query;

SKIP: {
    skip "Need API key, extractor ID, and target URL...", 3 unless ($api_key && $extractor_id && $target_url);
    ok( $importio->last_query_response->code eq '200', "Our response came back with a 200 OK for live_extractor_query." );
    ok( defined($live_scrape_result), "We received content via our HTTP request." );
    ok( ref($live_scrape_result) eq 'HASH', "We were able to deserialize our content." );
};

$live_scrape_result = $importio_apikey_fail->live_extractor_query;

SKIP: {
    skip "Need extractor ID and target URL...", 2, unless ($extractor_id && $target_url);
    ok( $importio_apikey_fail->last_query_response->code eq '400', "Our response came back with a 400 Bad Request for live_extractor_query when given a bad API key." );
    ok( !defined($live_scrape_result), "We didn't receive content back as expected (deserialization likely failed and caught an error)." );
};

$importio->extractor_id("broken_extractor_id");
$live_scrape_result = $importio->live_extractor_query;

SKIP: {
    skip "Need API key and target URL...", 1 unless ($api_key && $target_url);
    ok( $importio->last_query_response->code eq '500', "Our response came back with a 500 Bad Request for live_extractor_query when given a bad extractor ID." );
};

done_testing();
