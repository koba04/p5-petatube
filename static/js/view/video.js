(function() {

PetaTube.View.Video = Backbone.View.extend({
  player: null,
  el: "#play-video",
  initialize: function(args) {
    this.videos = args.videos;
    this.videos.on("reset", this.resetPlay, this);
  },
  events: {
    "click #prev-button": "prev",
    "click #next-button": "next",
  },
  next: function() {
    var nextId = this.videos.next();
    if ( nextId ) {
      this.play(nextId);
    }
  },
  prev: function() {
    var prevId = this.videos.prev();
    if ( prevId ) {
      this.play(prevId);
    }
  },
  resetPlay: function(videos) {
    var video = videos.at(this.videos.currentIndex);
    if ( video ) {
      this.play(video.id);
    }
  },
  play : function(videoId) {
    if ( !videoId ) {
      return;
    }
    if ( this.player ) {
        this.player.loadVideoById(videoId);
    } else {
      this.initSwf(videoId);
    }
    var tmpl = $('#tmpl-button').html();
    var $panel = _.template(tmpl, { current: this.videos.currentIndex + 1, total: this.videos.length });
    this.$el.find("#video-panel").html($panel);

  },
  initSwf: function(videoId) {
    var self = this;
    // https://developers.google.com/youtube/iframe_api_reference
    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    window.onYouTubeIframeAPIReady = function() {
      self.player = new YT.Player('video', {
        height: '450',
        width: '800',
        videoId: videoId,
        events: {
          'onReady': function(e) {
            // doesn't play video on iphone.
            // e.target.playVideo()
          },
          'onStateChange': function(e) {
            var state = e.data;
            if (state == YT.PlayerState.ENDED) {
              self.play(self.videos.next());
            }
          },
          'onError': function(e) {
            self.play(self.videos.next());
          }
        }
      });
    };
  }
});

})();
