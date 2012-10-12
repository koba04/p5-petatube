package PetaTube::Hot;
use strict;
use warnings;
use utf8;
use Digest::MurmurHash qw/murmur_hash/;
use List::Util qw/shuffle/;
use PetaTube::DB;
use PetaTube::Cache;

my $cache_version = 1;

sub fetch {
    my $class = shift;
    my %arg = @_;
    my $limit = $arg{limit} ? $arg{limit} : 10;

    my $cache = PetaTube::Cache->new;
    my $pages = $cache->get_callback('hot_pages?v='.$cache_version, sub {
        my $db = PetaTube::DB->new;
        return [
            map { { url => $_->url, title => $_->title } }
            $db->search(peta =>
                {
                    view_count => { '>' => 1 },
                    video_count => { '>' => 2 },
                },
                {
                    order_by => { view_count => 'DESC' },
                    limit => 10
                }
            )->all
        ];
    }, 60 * 60) || [];
    my @shuffled_pages = shuffle @$pages;
    return [ splice(@shuffled_pages, 0, $limit) ];
}

sub record {
    my $class = shift;
    my ($url, $title, $video_count) = @_;

    return unless $url;

    my $db = PetaTube::DB->new;
    my $row = $db->single(peta => { digest => murmur_hash($url), url => $url});
    if ( $row ) {
        $row->update({ view_count => \'view_count + 1', video_count => $video_count });
    } else {
        $row = $db->insert(peta => {
            digest      => murmur_hash($url),
            url         => $url,
            title       => $title,
            view_count  => 1,
            video_count => $video_count,
            created_at  => \'NOW()',
        });
    }
    return $row;
}

1;
