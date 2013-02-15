package PetaTube;
use strict;
use warnings;
use utf8;
use URI;
use Coro;
use Coro::Select;
use Furl;
use WebService::YouTube::Lite;
use PetaTube::Cache;

my $cache_version = 5;
my $youtube = WebService::YouTube::Lite->new;

sub extract_video_ids {
    my $class = shift;
    my ($url) = @_;

    my $cache = PetaTube::Cache->new;
    return $cache->get_callback("extract_video_ids?url=$url&v=$cache_version", sub {
        my $res = $youtube->extract_video_ids($url);

        if ( $url =~ m{^http://matome\.naver\.jp} ) {
            my $video_ids = $class->_extract_id_naver_matome_paging($url);
            push @{ $res->{ids} }, @$video_ids;
        }

        return $res;
    }, 60 * 60);
}

sub fetch_video {
    my $class = shift;
    my ($video_id) = @_;

    my $cache = PetaTube::Cache->new;
    return $cache->get_callback("fetch_by_id?id=$video_id&v=$cache_version", sub {
        $youtube->fetch_by_id($video_id);
    }, 60 * 60 * 24);
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
