package PetaTube::Video;
use strict;
use warnings;
use utf8;
use URI;
use Coro;
use Coro::Select;
use Encode;
use Furl;
use JSON::XS;
use WebService::YouTube::Lite;
use Amon2::Declare;

my $youtube = WebService::YouTube::Lite->new;
my $json = JSON::XS->new->utf8(1);

sub extract_video_ids {
    my $class = shift;
    my ($url) = @_;

    my $res = c->redis->hget('video_ids' => $url);
    if ( $res ) {
        c->redis->zincrby("view_score", 1, $url);
        return $json->decode($res);
    }

    $res = $youtube->extract_video_ids($url);
    if ( $url =~ m{^http://matome\.naver\.jp} ) {
         my $video_ids = $class->_extract_id_naver_matome_paging($url);
         push @{ $res->{ids} }, @$video_ids;
    }
    $res->{thumbnailVideoId} = $res->{ids}->[ int rand @{ $res->{ids} }];
    $res->{videoCount} = scalar @{$res->{ids}};
    $res->{title} = decode_utf8($res->{title});

    c->redis->hset('video_ids', $url => $json->encode($res));
    c->redis->zincrby("view_score", 1, $url);
    return $res;
}

sub fetch_video {
    my $class = shift;
    my ($video_id) = @_;

    my $res = c->redis->hget('video_info' => $video_id);
    return $json->decode($res) if $res;

    $res = $youtube->fetch_by_id($video_id);
    c->redis->hset('video_info', $video_id => $json->encode($res));
    return $res;
}

sub hot {
    my $class = shift;
    my $urls = c->redis->zrevrange("view_score", 0, 20);
    my $res = [];
    for my $url (@$urls) {
        my $info = $json->decode(c->redis->hget('video_ids' => $url));
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
