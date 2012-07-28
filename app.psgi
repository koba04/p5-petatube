use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use JSON;
use Furl;

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
    my @ids = ();
    my $status;
    # TODO cache
    if ( $url ) {
        my $furl = Furl->new;
        my $res = $furl->get($url);
        $status = $res->status;
        die $res->status_line unless $res->is_success;
        @ids = ($res->content =~ m{http://www\.youtube\.com/watch\?v=([a-zA-Z0-9\-_]+)&}sg);
    }
    return $c->render_json({ video_ids => encode_json(\@ids), status => $status });
};

get '/api/video' => sub {
    my $c = shift;

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
<script src="[% uri_for('/static/js/main.js') %]"></script>
<script src="[% uri_for('/static/js/lib/underscore.js') %]"></script>
<script src="[% uri_for('/static/js/lib/backbone.js') %]"></script>
<script src="[% uri_for('/static/js/app.js') %]"></script>
<link rel="stylesheet" href="[% uri_for('/static/css/main.css') %]">
</head>
<body>
<div class="container">
  <header><h1>PetaTube</h1></header>
  <section class="row">
    YouTubeの動画があるページのURLを貼ってね<br />
    <form action="/" method="GET">
      <input type="text" name="url" value="[% target_url %]"><input type="submit" value="検索">
    </form>
  </section>
  <footer>Powered by <a href="http://amon.64p.org/">Amon2::Lite</a></footer>
</div>
</body>
</html>
