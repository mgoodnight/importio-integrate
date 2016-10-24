#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;
use ImportIO::Integrate;

my $api_key = $ENV{IMPORTIO_API_KEY};
my $extractor_id = $ENV{IMPORTIO_EXTRACTOR_ID};

my $importio = ImportIO::Integrate->new(api_key => $api_key, extractor_id => $extractor_id);
isa_ok($importio, 'ImportIO::Integrate');

like( $importio->get_google_sheets_formula, qr/=IMPORTDATA/, "We generated a valid Google sheets formula." );

done_testing();
