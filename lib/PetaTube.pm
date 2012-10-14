package PetaTube;
use strict;
use warnings;
use utf8;
use Furl;
use WebService::YouTube::Lite;
use PetaTube::Cache;

my $cache_version = 3;
my $youtube = WebService::YouTube::Lite->new;

sub extract_video_ids {
    my $class = shift;
    my ($url) = @_;

    my $cache = PetaTube::Cache->new;
    return $cache->get_callback("extract_video_ids?url=$url&v=$cache_version", sub {
        $youtube->extract_video_ids($url);
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

1;
