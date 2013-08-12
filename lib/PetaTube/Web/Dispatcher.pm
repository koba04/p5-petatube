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

get '/api/page' => sub {
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

# for fetch of backbone model
get '/api/video/{id}' => sub {
    my $c = shift;
    my ($m) = @_;
    my $video_id = $m->{id} || '';
    my $res = {};
    # get youtube video info
    if ( $video_id ) {
        $res = PetaTube::Video->fetch_video($video_id);
    }
    return $c->render_json($res || {});
};

get '/api/hot' => sub {
    my $c = shift;
    my $hot_pages = PetaTube::Video->hot;
    return $c->render_json($hot_pages);
};

1;
