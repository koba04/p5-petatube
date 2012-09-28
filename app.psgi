use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use WebService::YouTube::Lite;
use PetaTube::Cache;

our $VERSION = '0.01';
my $youtube = WebService::YouTube::Lite->new;
my $cache = PetaTube::Cache->new;
my $cache_version = 1;

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

    my $recommends = [
        {
            title   => "『邦楽ロックバンド 解散ライブの動画』まとめ",
            url     => "http://matome.naver.jp/odai/2132876130063084301",
        },
        {
            title   => "【動画大量】UKロックのおすすめバンド貼って行こうぜ！！！",
            url     => "http://blog.livedoor.jp/kinisoku/archives/3401781.html",
        },
        {
            title   => "邦楽ロックバンドNo.1決定戦",
            url     => "http://onsoku.info/archives/51585586.html",
        },
    ];

    return $c->render('index.tt', { recommends => $recommends });
};

get '/api/site' => sub {
    my $c = shift;

    my $url = $c->req->param('url') || '';
    my $ids = [];
    my $status = '';
    if ( $url ) {
        $ids = $cache->get_callback("extract_video_ids?$cache_version", sub {
            my $result = $youtube->extract_video_ids($url);
            return [ map { {id => $_} } @{ $result->{ids} } ];
        });
    }
    return $c->render_json({ video_ids => $ids });
};

# for fetch of backbone model
get '/api/video/{id}' => sub {
    my $c = shift;
    my ($m) = @_;
    my $video_id = $m->{id} || '';
    my $res = {};
    # get youtube video info
    if ( $video_id ) {
        $res = $cache->get_callback("fetch_by_id?$cache_version", sub {
            return $youtube->fetch_by_id($video_id);
        });
    }
    return $c->render_json($res);
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
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
<script src="<: uri_for('/static/js/lib/underscore.js') :>"></script>
<script src="<: uri_for('/static/js/lib/backbone.js') :>"></script>
<script src="<: uri_for('/static/js/app.js') :>"></script>
<script src="<: uri_for('/static/js/model/video.js') :>"></script>
<script src="<: uri_for('/static/js/collection/videos.js') :>"></script>
<script src="<: uri_for('/static/js/view/search.js') :>"></script>
<script src="<: uri_for('/static/js/view/video.js') :>"></script>
<script src="<: uri_for('/static/js/view/videos.js') :>"></script>
<link rel="stylesheet" href="<: uri_for('/static/css/main.css') :>">
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
<h1>PetaTube</h1>
<div id="menu">
  <a href="#recommend" class="open-modal">recommend</a>&nbsp;
  <a href="#about" class="open-modal">about</a>&nbsp;
  <a href="javascript:window.location='http://petatube.koba04.com/?' + window.location;">peta</a><span>(bookmaklet)</span>
</div>
</header>
<section id="about">
  <a href="#" class="close-modal"></a>
  <div>
    <h1>PetaTubeとは?</h1>
    <dl>
      <dt>ペタっとURL貼るだけ</dt>
      <dd>
        YouTubeの動画が貼ってあるページのURLをペタっと貼り付けると<br />
        そのページにある再生可能な動画を連続再生することが出来るだけのサービスです
      </dd>
      <dt>スマートフォンもOK</dt>
      <dd>
        Flash非搭載なiPhoneでも動作します<br />
        Peta(bookmarklet)をブックマークして動画のあるページで押すとそのページの動画を再生することが出来ます
      </dd>
      <dt>ブックマークレットで簡単Play</dt>
      <dd>
        メニューにある「peta」をブックマークしておくことで、YouTubeの動画があるページでブックマークをクリックするだけで再生出来ます
      </dd>
      <dt>注意点</dt>
      <dd>
        URLの指定のされ方によっては動画が取得出来ないことがあります
      </dd>
    </dl>
  </div>
</section>
<section id="recommend">
  <a href="#" class="close-modal"></a>
  <div>
    <h1>おすすめ</h1>
    <ul>
    : for $recommends -> $recommend {
      <li><a href="/?<: $recommend.url :>"><: $recommend.title :></a></li>
    : }
    </ul>
  </div>
</section>
<section id="main">
  <div id="play-video">
    <div id="video-info"></div>
    <div id="video"></div>
    <div id="video-panel"></div>
    <script type="text/x-tmpl" id="tmpl-button">
      <input type="button" id="prev-button" value="&lt;&lt;">
      <span class="play-index"><%= current %></span>/<span class="play-index"><%= total %></span>
      <input type="button" id="next-button" value="&gt;&gt;">
    </script>
  </div>
  <div id="input-url">
    <form action="#" method="GET">
      <input type="text" size="50" name="url" value="" placeholder="YouTubeの動画があるページのURLを貼ってね">
      <input type="submit" value="play">
    </form>
  </div>
  <div id="video-list"></div>
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
<div class="fb-like" data-href="http://petatube.koba04.com/" data-send="false" data-layout="button_count" data-width="50" data-show-faces="false" data-font="arial"></div>
  <span class="tweet">
    <a href="https://twitter.com/intent/tweet?screen_name=koba04&text=http%3A%2F%2Fpetatube.koba04.com%2F%20" class="twitter-mention-button" data-lang="ja" data-related="koba04">Tweet to @koba04</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
    <a href="https://twitter.com/share" class="twitter-share-button" data-via="koba04" data-lang="ja" data-hashtags="petatube">ツイート</a>
    <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
  </span>
</footer>
<script>
</script>
</body>
</html>
