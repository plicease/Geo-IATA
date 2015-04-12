use strict;
use warnings;

use Test::More tests => 4;                      # last test to print
use_ok("Geo::IATA");
my $iata;
eval {
  $iata=Geo::IATA->new();
};
is ($@,'', "new doesn't die");
ok (defined $iata, "\$iata is defined");

ok (defined $iata->iata("SXF"), "SXF iata code returns record");

