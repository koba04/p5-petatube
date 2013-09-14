package PetaTube::Video;
use strict;
use warnings;
use utf8;
use URI;
use Coro;
use Coro::Select;
use Encode;
use List::Util qw/shuffle/;
use Amon2::Declare;

sub extract_video_ids {
    my $class = shift;
    my ($url) = @_;

    my $result = $class->fetch_video_ids($url);
    c->redis->incr_score("view_score" => $url);
    return $result;
}

sub fetch {
    my $class = shift;
    my ($video_id) = @_;

    c->redis->get_callback('video_info', $video_id => sub {
        return c->youtube->fetch_by_id($video_id);
    }, 60 * 60);
}

sub fetch_video_ids {
    my $class = shift;
    my ($url) = @_;
    c->redis->get_callback('video_ids', $url => sub {
        my $res = c->youtube->extract_video_ids($url);
        if ( $url =~ m{^http://matome\.naver\.jp} ) {
             my $video_ids = $class->_extract_id_naver_matome_paging($url);
             push @{ $res->{ids} }, @$video_ids;
        }
        $res->{thumbnailVideoId} = $res->{ids}->[ int rand @{ $res->{ids} }];
        $res->{videoCount} = scalar @{$res->{ids}};
        $res->{title} = decode_utf8($res->{title});
        return $res;
    }, 60 * 60);
}

sub popular {
    my $class = shift;
    my ($limit) = @_;
    my $urls = c->redis->rank_range("view_score", 1, 20);
    my @shuffled_urls = shuffle @$urls;
    my $res = [];
    for my $i (1..5) {
        my $url = $shuffled_urls[$i];
        my $info = $class->fetch_video_ids($url);
        $info->{url} = $url;
        push @$res, $info;
    }
    return $res;
}

# fetch naver matome other paging and extract video ids
sub _extract_id_naver_matome_paging {
    my $class = shift;
    my ($url) = @_;

    my $response = c->http->get($url);

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
            my $res = c->youtube->extract_video_ids($paging_url);
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

=item my $video = PetaTube::Video->fetch_video_ids($url);

    fetch extract video ids by url

=item my $result = PetaTube::Video->popular

    get popular pages

