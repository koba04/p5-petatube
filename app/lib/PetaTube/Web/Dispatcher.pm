package PetaTube::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

use PetaTube::Video;

any '/' => sub {
    my ($c) = @_;
    return $c->render('index.tt');
};

get '/videos/{id}' => sub {
    my $c = shift;
    my ($m) = @_;
    my $video_id = $m->{id} || '';
    my $res = {};
    # get youtube video info
    if ( $video_id ) {
        $res = PetaTube::Video->fetch($video_id);
    }
    return $c->render_json($res || {});
};


get '/videos/' => sub {
    my $c = shift;

    my $url = $c->req->param('url') || '';
    my $video_ids = [];
    my $title = '';
    if ( $url ) {
        my $result = PetaTube::Video->extract_video_ids($url);
        $video_ids = $result->{ids};
        $title = $result->{title};
    }
    return $c->render_json({
        video_ids   => [ map { {id => $_} } @$video_ids ],
        url         => $url,
        title       => $title,
    });
};

get '/popular' => sub {
    my $c = shift;
    my $popular_pages = PetaTube::Video->popular(5);
    return $c->render_json($popular_pages);
};

1;
