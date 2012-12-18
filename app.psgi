use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use PetaTube;
use PetaTube::Hot;

our $VERSION = '0.01';
my $static_version = 5;

# put your configuration here
sub load_config {
    my $c = shift;

    my $mode = $c->mode_name || 'development';
    return {
        'Text::Xslate' => {
            syntax => 'Kolon',
        },
    };
}

get '/' => sub {
    my $c = shift;
    return $c->render('index.tt', { static_version => $static_version });
};

get '/api/page' => sub {
    my $c = shift;

    my $url = $c->req->param('url') || '';
    my $video_ids = [];
    my $title = '';
    if ( $url ) {
        my $result = PetaTube->extract_video_ids($url);
        $video_ids = $result->{ids};
        $title = PetaTube::Hot->record($url, $result->{title}, scalar @$video_ids)->title;
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
        $res = PetaTube->fetch_video($video_id);
    }
    return $c->render_json($res || {});
};

get '/api/hot' => sub {
    my $c = shift;

    my $hot_pages = PetaTube::Hot->fetch(limit => 5);
    return $c->render_json($hot_pages);
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
<meta name="viewport" content="width=900" />
<meta name="description" content="PetaTubeはYouTubeの動画が貼ってあるページのURLを入れるだけで連続再生出来るサービスです。" />
<meta property="fb:admins" content="100001278582922" />
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
<script src="<: uri_for('/static/js/lib/underscore.js') :>"></script>
<script src="<: uri_for('/static/js/lib/backbone.js') :>"></script>
<script src="<: uri_for('/static/js/app.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/model/video.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/model/hot-page.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/collection/videos.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/collection/hot-pages.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/view/search.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/view/video.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/view/videos.js', { v => $static_version }) :>"></script>
<script src="<: uri_for('/static/js/view/hot-pages.js', { v => $static_version }) :>"></script>
<link rel="stylesheet" href="<: uri_for('/static/css/main.css', { v => $static_version }) :>">
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-8875970-3']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
</head>
<body>
<header>
<h1><a href="/">PetaTube</a></h1>
<div id="menu">
  <a href="#about" class="open-modal">about</a>&nbsp;
  <a href="javascript:window.location='http://petatube.koba04.com/?' + window.location;">peta</a><span>(bookmaklet)</span>
</div>
</header>
<section id="about">
  <a href="#" class="close-modal"></a>
  <div>
    <h1>PetaTubeとは?</h1>
    <dl>
      <dt>ペタっとURLを貼るだけ</dt>
      <dd>
        YouTubeの動画が貼ってあるページのURLをペタっと貼り付けると<br />
        そのページにある再生可能な動画を連続再生することが出来るだけのサービスです<br />
        URLの指定のされ方によっては動画が取得出来ないことがあります
      </dd>
      <dt>ブックマークレットで簡単Play</dt>
      <dd>
        メニューにある「peta」をブックマークしておくことで、YouTubeの動画があるページでブックマークをクリックするだけで再生出来ます
      </dd>
      <dt>more</dt>
      <dd>
        <a href="http://d.hatena.ne.jp/koba04/20121002/1349103920">http://d.hatena.ne.jp/koba04/20121002/1349103920</a>
      </dd>
    </dl>
  </div>
</section>
<section id="main">
  <div id="play-video">
    <div id="video-info"></div>
    <div id="video"></div>
    <div id="video-panel"></div>
    <script type="text/x-tmpl" id="tmpl-button">
      <input type="button" id="prev-button" value="&lt;&lt;" />
      <span class="play-index"><%= current %></span>/<span class="play-index"><%= total %></span>
      <input type="button" id="next-button" value="&gt;&gt;" />
      <input type="button" id="shuffle-button" value="shuffle" />
    </script>
  </div>
  <div id="input-url">
    <div id="play-url"></div>
    <form action="#" method="GET">
      <input type="text" size="50" name="url" value="" placeholder="YouTubeの動画があるページのURLを貼ってください">
      <input type="submit" value="play">
    </form>
  </div>
  <div id="hot">
    <h2>みんなが見た動画</h2>
  </div>
</section>
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/ja_JP/all.js#xfbml=1&appId=346463362115366";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));
  $(".open-modal").click(function() {
    $(".fb-like").hide();
  });
  $(".close-modal").click(function() {
    $(".fb-like").show();
  });
</script>
<footer>
  <span>&copy; <a href="http://about.me/koba04">koba04</a></span>
  <span>Powered by <a href="http://amon.64p.org/">Amon2::Lite</a></span>
  <span class="fb-like" data-href="http://petatube.koba04.com/" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-font="arial"></span>
  <span class="tweet">
    <a href="https://twitter.com/intent/tweet?screen_name=koba04&text=http%3A%2F%2Fpetatube.koba04.com%2F%20" class="twitter-mention-button" data-lang="ja" data-related="koba04">Tweet to @koba04</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
<a href="https://twitter.com/share" class="twitter-share-button" data-lang="ja" data-hashtags="petatube">ツイート</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
  </span>
</footer>
<script>
</script>
</body>
</html>
