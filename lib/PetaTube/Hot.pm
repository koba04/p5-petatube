package PetaTube::Hot;
use strict;
use warnings;
use utf8;
use Digest::MurmurHash qw/murmur_hash/;
use List::Util qw/shuffle/;
use PetaTube::DB;
use PetaTube::Cache;

my $cache_version = 4;

sub fetch {
    my $class = shift;
    my %arg = @_;
    my $limit = $arg{limit} ? $arg{limit} : 10;

    my $cache = PetaTube::Cache->new;
    my $pages = $cache->get_callback('hot_pages?v='.$cache_version, sub {
        my $db = PetaTube::DB->new;
        return [
            map { { url => $_->url, title => $_->title, videoCount => $_->video_count, thumbnailVideoId => $_->thumbnail_video_id } }
            $db->search(peta =>
                {
                    title       => { '!=' => '' }, # XXX performance
                    view_count  => { '>' => 4 },
                    video_count => { '>' => 4 },
                },
                {
                    order_by => { view_count => 'DESC' },
                    limit => 50
                }
            )->all
        ];
    }, 60 * 60) || [];
    my @shuffled_pages = shuffle @$pages;
    return [ splice(@shuffled_pages, 0, $limit) ];
}

sub record {
    my $class = shift;
    my ($url, $title, $video_ids) = @_;

    return unless $url;

    my $db = PetaTube::DB->new;
    my $row = $db->single(peta => { digest => murmur_hash($url), url => $url});

    my %cond = (
        title               => $title,
        video_count         => scalar @$video_ids,
        thumbnail_video_id  => $video_ids->[ int rand @$video_ids],
    );

    if ( $row ) {
        $row->update({
            %cond,
            view_count  => \'view_count + 1',
        });
        $row = $row->refetch;
    } else {
        $row = $db->insert(peta => {
            %cond,
            digest      => murmur_hash($url),
            url         => $url,
            view_count  => 1,
            created_at  => \'NOW()',
        });
    }
    return $row;
}

1;
