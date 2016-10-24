#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use ImportIO::Integrate;
use XML::RSS;

my $api_key = $ENV{IMPORTIO_API_KEY};
my $extractor_id = $ENV{IMPORTIO_EXTRACTOR_ID};

my $importio = ImportIO::Integrate->new(api_key => $api_key, extractor_id => $extractor_id);
my $importio_apikey_fail = ImportIO::Integrate->new(api_key => 'acb1234_bad', extractor_id => $extractor_id);
isa_ok($importio_apikey_fail, 'ImportIO::Integrate');
isa_ok($importio, 'ImportIO::Integrate');

my $last_live_info = $importio->last_live_query_info;
my $parser = XML::RSS->new();

SKIP: {
    skip "Need API key and extractor ID...", 4 unless ($api_key && $extractor_id);
    ok( $importio->last_query_response->code eq '200', "Our response came back with a 200 OK for last_live_query_info." );
    ok( defined($last_live_info), "We received content via our HTTP request." );

    $parser->parse($last_live_info);
    my $title = $parser->channel->{title};
    
    ok( "Runs for Extractor $extractor_id" eq $title, "Parsed RSS data successfully and verified this is the feed to the given extractor ID." );
    ok( scalar(@{$parser->{items}}) > 0, "We have items within the RSS feed." );
};

$last_live_info = $importio_apikey_fail->last_live_query_info;

SKIP: {
    skip "Need extractor ID...", 2, unless ($extractor_id);
    ok( $importio_apikey_fail->last_query_response->code eq '400', "Our response came back with a 400 Bad Request for live_extractor_query when given a bad API key." );
    like( $last_live_info, qr/400 Bad Request/i, "Content contains server error information." );
};

$importio->extractor_id("broken_extractor_id");
$last_live_info = $importio->last_live_query_info;

SKIP: {
    skip "Need API key...", 4 unless ($api_key);
	ok( $importio->last_query_response->code eq '200', "Our response came back with a 200 OK for last_live_query_info." );
    ok( defined($last_live_info), "We received content via our HTTP request." );

	$parser->parse($last_live_info);
    my $title = $parser->channel->{title};

	ok( "Runs for Extractor " . $importio->extractor_id eq $title, "Parsed RSS data successfully and verified this is the feed to the given extractor ID." );
	ok( scalar(@{$parser->{items}}) == 0, "Since we gave a bad extractor ID, we should of no items within the RSS." );
};

done_testing();
