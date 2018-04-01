#!perl
use Test::More;

use_ok 'WebService::GetSongBPM';

my $obj = eval { WebService::GetSongBPM->new };
isa_ok $obj, 'WebService::GetSongBPM';

done_testing();
