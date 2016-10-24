#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use ImportIO::Integrate;

my $api_key = $ENV{IMPORTIO_API_KEY};
my $extractor_id = $ENV{IMPORTIO_EXTRACTOR_ID};

my $importio = ImportIO::Integrate->new(api_key => $api_key, extractor_id => $extractor_id);
my $importio_apikey_fail = ImportIO::Integrate->new(api_key => 'acb1234_bad', extractor_id => $extractor_id);
isa_ok($importio_apikey_fail, 'ImportIO::Integrate');
isa_ok($importio, 'ImportIO::Integrate');

my $last_csv_result = $importio->last_run_csv_query;

SKIP: {
    skip "Need API key and extractor ID...", 3 unless ($api_key && $extractor_id);
    ok( $importio->last_query_response->code eq '200', "Our response came back with a 200 OK for last_run_csv_query." );
    ok( defined($last_csv_result), "We received content via our HTTP request." );
    like( $last_csv_result, qr/"\w+",/, "We received CSV serialized content." );
};

$last_csv_result = $importio_apikey_fail->last_run_csv_query;

SKIP: {
    skip "Need extractor ID...", 2, unless ($extractor_id);
    ok( $importio_apikey_fail->last_query_response->code eq '400', "Our response came back with a 400 Bad Request for live_extractor_query when given a bad API key." );
    unlike( $last_csv_result, qr/"\w+",/, "We didn't receive any CSV data back as expected." );
};

$importio->extractor_id("broken_extractor_id");
$last_csv_result = $importio->last_run_csv_query;

SKIP: {
    skip "Need API key...", 1 unless ($api_key);
    ok( $importio->last_query_response->code eq '302', "Our response came back with a 302 Temporarily Moved for last_run_csv_query when given a bad extractor ID." );
};

done_testing();
