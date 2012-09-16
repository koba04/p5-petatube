use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use JSON;
use YouTubeVideo;

our $VERSION = '0.01';

# put your configuration here
sub load_config {
    my $c = shift;

    my $mode = $c->mode_name || 'development';
    return {};
}

get '/' => sub {
    my $c = shift;
    return $c->render('index.tt');
};

get '/api/site' => sub {
    my $c = shift;

    my $url = $c->req->param('url') || '';
    my $ids = [];
    my $status = '';
    # TODO cache
    if ( $url ) {
        my $result = YouTubeVideo::fetch_by_url($url);
        $ids = [ map { {id => $_} } @{ $result->{ids} } ];
        $status = $result->{status};
    }
    return $c->render_json({ video_ids => $ids, status => $status });
};

get '/api/video' => sub {
    my $c = shift;

    # get youtube video info
};

# load plugins
__PACKAGE__->load_plugin('Web::JSON');
__PACKAGE__->to_app(handle_static => 1);

__DATA__

@@ index.tt
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>PetaTube</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>
<script src="[% uri_for('/static/js/lib/underscore.js') %]"></script>
<script src="[% uri_for('/static/js/lib/backbone.js') %]"></script>
<script src="[% uri_for('/static/js/app.js') %]"></script>
<script src="[% uri_for('/static/js/model/video.js') %]"></script>
<script src="[% uri_for('/static/js/collection/videos.js') %]"></script>
<script src="[% uri_for('/static/js/view/search.js') %]"></script>
<script src="[% uri_for('/static/js/view/video.js') %]"></script>
<script src="[% uri_for('/static/js/view/videos.js') %]"></script>
<link rel="stylesheet" href="[% uri_for('/static/css/main.css') %]">
</head>
<body>
<div class="container">
  <header>
    <h1>PetaTube</h1>
  </header>
  <section id="play-video">
    <div id="video"></div>
    <div id="input-url">
        <form action="#" method="GET">
          <input type="text" size="50" name="url" value="" placeholder="YouTubeの動画があるページのURLを貼ってね">
          <input type="submit" value="検索">
        </form>
    </div>
    <div id="recommend">
        <a href="/?http://matome.naver.jp/odai/2132876130063084301">『邦楽ロックバンド 解散ライブの動画』まとめ</a>
    </div>
  </section>
  <section id="video-list">
  </section>
  <footer>
    <span>&copy; koba04</span>
    <span>Powered by <a href="http://amon.64p.org/">Amon2::Lite</a></span>
  </footer>
</div>
</body>
</html>
