use strict;
use warnings;

use Test::More tests => 3;
use Data::Dumper;

BEGIN { use_ok( 'Alien::NSS::ConfigData' ); }

my $pkgconfig = Alien::NSS::ConfigData->config('pkgconfig');
ok(defined($pkgconfig), 'got pkgconfig');
diag(Dumper($pkgconfig));
is(scalar keys $pkgconfig, 1, 'only 1 key in pkgconfig');
