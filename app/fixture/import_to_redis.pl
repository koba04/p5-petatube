#!perl

use utf8;
use strict;
use warnings;

use File::Spec;
use FindBin;
use PetaTube;
use PetaTube::Video;

my $c = PetaTube->bootstrap;

my $tsv_path = File::Spec->catfile($FindBin::Bin, "peta.tsv");
open my $fh, '<:encoding(UTF-8)', $tsv_path or die "$tsv_path: $!";
my @data = split /\n/, do { local $/; <$fh> };
# delete header record
shift @data;
warn "@data";

for my $record (@data) {
    my ($url, $title, $view_count, $video_count, $thumbnail_video_id) = split /\t/, $record;
    warn "$view_count: $url";
    $c->redis->incr_score("view_score", $url => $view_count);
}
