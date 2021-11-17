package WebService::GetSongBPM;

# ABSTRACT: Access to the getsongbpm.com API

our $VERSION = '0.0400';

use Moo;
use strictures 2;
use namespace::clean;

use Carp;
use Mojo::UserAgent;
use Mojo::JSON::MaybeXS;
use Mojo::JSON qw( decode_json );
use Mojo::URL;
use Try::Tiny;

=head1 SYNOPSIS

  use WebService::GetSongBPM;
  my $ws = WebService::GetSongBPM->new(
    api_key => '1234567890abcdefghij',
    artist  => 'van halen',
    song    => 'jump',
  );
  # OR
  $ws = WebService::GetSongBPM->new(
    api_key   => '1234567890abcdefghij',
    artist_id => 'abc123',
  );
  # OR
  $ws = WebService::GetSongBPM->new(
    api_key => '1234567890abcdefghij',
    song_id => 'xyz123',
  );
  my $res = $ws->fetch();
  my $bpm = $res->{song}{tempo};

=head1 DESCRIPTION

C<WebService::GetSongBPM> provides access to L<https://getsongbpm.com/api>.

=head1 ATTRIBUTES

=head2 api_key

Your authorized access key.

=cut

has api_key => (
    is       => 'ro',
    required => 1,
);

=head2 base

The base URL.  Default: https://api.getsongbpm.com

=cut

has base => (
    is      => 'rw',
    default => sub { 'https://api.getsongbpm.com' },
);

=head2 artist

The artist for which to search.

=cut

has artist => (
    is => 'ro',
);

=head2 artist_id

The artist id for which to search.

=cut

has artist_id => (
    is => 'ro',
);

=head2 song

The song for which to search.

=cut

has song => (
    is => 'ro',
);

=head2 song_id

The song id for which to search.

=cut

has song_id => (
    is => 'ro',
);

=head2 ua

The user agent.

=cut

has ua => (
    is      => 'rw',
    default => sub { Mojo::UserAgent->new() },
);

=head1 METHODS

=head2 new()

  $ws = WebService::GetSongBPM->new(%arguments);

Create a new C<WebService::GetSongBPM> object.

=head2 fetch()

  $r = $w->fetch();

Fetch the results and return them as a HashRef.

=cut

sub fetch {
    my ($self) = @_;

    my $type;
    my $lookup;
    my $id;

    if ( $self->artist && $self->song ) {
        $type   = 'both';
        $lookup = 'song:' . $self->song . '+artist:' . $self->artist;
    }
    elsif ( $self->artist or $self->artist_id ) {
        $type   = 'artist';
        $lookup = $self->artist;
        $id     = $self->artist_id;
    }
    elsif ( $self->song or $self->song_id ) {
        $type   = 'song';
        $lookup = $self->song;
        $id     = $self->song_id;
    }
    croak "Can't fetch: No type set"
        unless $type;

    my $path  = '';
    my $query = {};

    if ( $self->artist_id or $self->song_id ) {
        $path .= $type;
        $query = {
            api_key => $self->api_key,
            id      => $id,
        };
    }
    else {
        $path .= 'search';
        $query = {
            api_key => $self->api_key,
            type    => $type,
            lookup  => $lookup,
        };
    }

    my $url = Mojo::URL->new($self->base)->path($path)->query($query);

    my $tx = $self->ua->get($url);

    my $data = _handle_response($tx);

    return $data;
}

sub _handle_response {
    my ($tx) = @_;

    my $data;

    my $res = $tx->result;

    if ( $res->is_success ) {
        my $body = $res->body;
        try {
            $data = decode_json($body);
        }
        catch {
            croak $body, "\n";
        };
    }
    else {
        croak "Connection error: ", $res->message;
    }

    return $data;
}

1;

=head1 SEE ALSO

L<Moo>

L<Mojo::UserAgent>

L<Mojo::JSON::MaybeXS>

L<Mojo::JSON>

L<https://getsongbpm.com/api>

=cut
