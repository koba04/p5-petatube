(function () {
  "use strict";

  PetaTube.View.Video = Backbone.View.extend({
    player: null,
    el: "#play-video",
    initialize: function (args) {
      this.videos = args.videos;
      this.videos.on("reset", this.play, this);
    },
    events: {
      "click #prev-button": "prev",
      "click #next-button": "next",
      "click #shuffle-button": "shuffle"
    },
    // play next video
    next: function () {
      this.videos.next();
      this.play();
    },
    // play prev video
    prev: function () {
      this.videos.prev();
      this.play();
    },
    // skip can't play video
    skip: function () {
      this.videos.skip();
      this.play();
    },
    shuffle: function () {
      this.videos.shufflePlay();
    },
    // play current video
    play : function () {
      var video = this.videos.current();
      if (video.get('title')) {
        this.$el.find("#video-info").text(video.get('title'));
        $('title').text(video.get('title') + "(PetaTube)");
      } else {
        video.fetch({
          success: $.proxy(function () {
            this.$el.find("#video-info").text(video.get('title'));
            $('title').text(video.get('title') + "(PetaTube)");
          }, this)
        });
      }

      this.loadPlayer();
      var tmpl = $('#tmpl-button').html();
      var $panel = _.template(tmpl, { current: this.videos.currentIndex + 1, total: this.videos.length });
      this.$el.find("#video-panel").html($panel);
      this.$el.show();
    },
    loadPlayer: function () {
      var video = this.videos.current();
      // already create video player
      if (this.player) {
        return this.player.loadVideoById(video.id);
      }

      // https://developers.google.com/youtube/iframe_api_reference
      var tag = document.createElement('script');
      tag.src = "//www.youtube.com/iframe_api";
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
      window.onYouTubeIframeAPIReady = $.proxy(function () {
        this.player = new YT.Player('video', {
          height: '425',
          width: '760',
          videoId: video.id,
          events: {
            'onReady': function () {
              // doesn't play video on iphone.
              // e.target.playVideo()
            },
            'onStateChange': $.proxy(function (e) {
              var state = e.data;
              if (state === YT.PlayerState.ENDED) {
                this.next();
              }
            }, this),
            'onError': $.proxy(function () {
              this.skip();
            }, this)
          }
        });
      }, this);
    }
  });

})();
