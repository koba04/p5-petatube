(function() {

PetaTube.View.Video = Backbone.View.extend({
  player: null,
  el: "#play-video",
  initialize: function(args) {
    this.videos = args.videos;
    this.videos.on("reset", this.play, this);
  },
  events: {
    "click #prev-button": "prev",
    "click #next-button": "next",
    "click #shuffle-button": "shuffle"
  },
  // play next video
  next: function() {
    this.videos.next();
    this.play();
  },
  // play prev video
  prev: function() {
    this.videos.prev();
    this.play();
  },
  // skip can't play video
  skip: function() {
    this.videos.skip();
    this.play();
  },
  shuffle: function(e) {
    this.videos.shufflePlay();
  },
  // play current video
  play : function() {
    var video = this.videos.current();
    if ( video.get('title') ) {
      this.$el.find("#video-info").text(video.get('title'));
      $('title').text(video.get('title') + "(PetaTube)");
    } else {
      var self = this;
      video.fetch({
        success: function() {
          self.$el.find("#video-info").text(video.get('title'));
          $('title').text(video.get('title') + "(PetaTube)");
        }
      });
    }

    this.loadPlayer();
    var tmpl = $('#tmpl-button').html();
    var $panel = _.template(tmpl, { current: this.videos.currentIndex + 1, total: this.videos.length });
    this.$el.find("#video-panel").html($panel);
  },
  loadPlayer: function() {
    var self = this;

    var video = this.videos.current();
    // already create video player
    if ( self.player ) {
      return self.player.loadVideoById(video.id);
    }

    // https://developers.google.com/youtube/iframe_api_reference
    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    window.onYouTubeIframeAPIReady = function() {
      self.player = new YT.Player('video', {
        height: '450',
        width: '800',
        videoId: video.id,
        events: {
          'onReady': function(e) {
            // doesn't play video on iphone.
            // e.target.playVideo()
          },
          'onStateChange': function(e) {
            var state = e.data;
            if (state == YT.PlayerState.ENDED) {
              self.next();
            }
          },
          'onError': function(e) {
            self.skip();
          }
        }
      });
    };
  }
});

})();
