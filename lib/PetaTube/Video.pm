package PetaTube::Video;
use strict;
use warnings;
use utf8;
use URI;
use Coro;
use Coro::Select;
use Encode;
use Furl;
use WebService::YouTube::Lite;
use Amon2::Declare;

my $youtube = WebService::YouTube::Lite->new;

sub extract_video_ids {
    my $class = shift;
    my ($url) = @_;

    my $result = c->data_store->get_callback('video_ids', $url => sub {
        my $res = $youtube->extract_video_ids($url);
        if ( $url =~ m{^http://matome\.naver\.jp} ) {
             my $video_ids = $class->_extract_id_naver_matome_paging($url);
             push @{ $res->{ids} }, @$video_ids;
        }
        $res->{thumbnailVideoId} = $res->{ids}->[ int rand @{ $res->{ids} }];
        $res->{videoCount} = scalar @{$res->{ids}};
        $res->{title} = decode_utf8($res->{title});
        return $res;
    }, 60 * 60);
    c->data_store->incr_score("view_score" => $url);
    return $result;
}

sub fetch {
    my $class = shift;
    my ($video_id) = @_;

    c->data_store->get_callback('video_info', $video_id => sub {
        return $youtube->fetch_by_id($video_id);
    }, 60 * 60);
}

sub popular {
    my $class = shift;
    my $urls = c->data_store->rank_range("view_score", 1, 20);
    my $res = [];
    for my $url (@$urls) {
        my $info = c->data_store->get('video_ids' => $url);
        $info->{url} = $url;
        push @$res, $info;
    }
    return $res;
}

# fetch naver matome other paging and extract video ids
sub _extract_id_naver_matome_paging {
    my $class = shift;
    my ($url) = @_;

    my $ua = Furl->new;
    my $response = $ua->get($url);

    return [] unless $response->is_success;

    my $content = $response->content;

    # fetch paging no
    my @pages = $content =~ /goPage\((\d+)\);/g;
    my $uri = URI->new($url);

    # parallel http by coro
    my $video_ids = [];
    my @coros;
    for my $page ( @pages ) {
        push @coros, async {
            my $paging_url = $uri->clone;
            $paging_url->query_form(page => $page);
            warn "start =>" . $paging_url;
            my $res = $youtube->extract_video_ids($paging_url);
            push @$video_ids, @{ $res->{ids} };
        }
    }
    $_->join for @coros;
    return $video_ids;
}

1;
__END__
=head1 NAME PetaTube::Video

=head1 DESCRIPTION

  PetaTube's (youtube) video library

=head1 SYNOPSYS

    my $video = PetaTube::Video->fetch($video_id);
    my $result = PetaTube::Video->extract_video_ids("http://example.com/");

=head1 METHODS

=over 4

=item my $result = PetaTube::Video->extract_video_ids("http://example.com/")

    extract youtube's video id from target $url page.

=item my $video = PetaTube::Video->fetch($video_id);

    fetch youtube's video info

=item my $result = PetaTube::Video->popular

    get popular pages

