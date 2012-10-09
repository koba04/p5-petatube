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
    my ($limit) = @_;
    $limit ||= 10;

    my $cache = PetaTube::Cache->new;
    my $pages = $cache->get_callback('hot_pages?v='.$cache_version, sub {
        my $db = PetaTube::DB->new;
        return [
            map { { url => $_->url, title => $_->title } }
            $db->search(peta => {}, { order_by => { count => 'DESC' }, limit => 100 })->all
        ];
    }, 60 * 60) || [];
    return [ splice(shuffle(@$pages), 0, $limit) ];
}

sub record {
    my $class = shift;
    my ($url, $title) = @_;

    return unless $url;

    my $db = PetaTube::DB->new;
    my $row = $db->single(peta => { digest => murmur_hash($url), url => $url});
    if ( $row ) {
        $row->update({ count => \'count + 1' });
    } else {
        $db->insert(peta => {
            digest      => murmur_hash($url),
            url         => $url,
            title       => $title,
            count       => 1,
            created_at  => \'NOW()',
        });
    }
}

1;
