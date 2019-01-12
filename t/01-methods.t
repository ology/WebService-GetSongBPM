#!perl
use Test::More;
use Test::Exception;

use Mojo::Base -strict;
use Mojolicious;

use Try::Tiny qw(try catch);

use_ok 'WebService::GetSongBPM';

throws_ok { WebService::GetSongBPM->new }
    qr/Missing required arguments: api_key/, 'api_key required';

my $ws = WebService::GetSongBPM->new(
    api_key => '1234567890',
    artist  => 'van halen',
    song    => 'jump',
);
isa_ok $ws, 'WebService::GetSongBPM';

my $mock = Mojolicious->new;
$mock->log->level('fatal'); # only log fatal errors to keep the server quiet
$mock->routes->get('/search' => sub {
    my $c = shift;
    return $c->render(status => 400, text => 'Name does not resolve');
});
$ws->ua->server->app($mock); # point our UserAgent to our new mock server

$ws->base(Mojo::URL->new(''));

can_ok($ws, 'fetch');

my $data = try { $ws->fetch } catch { $_; };
use Data::Dumper;warn(__PACKAGE__,' ',__LINE__," MARK: ",Dumper$data);
# https://api.getsongbpm.com/search/?api_key=1234567890&type=both&lookup=song:jump+artist:van halen

done_testing();
