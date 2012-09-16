(function() {

PetaTube.View.Video = Backbone.View.extend({
  player: null,
  el: "#video",
  initialize: function(args) {
    this.videos = args.videos;
    this.videos.on("reset", this.resetPlay, this);
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
  },
  initSwf: function(videoId) {
    var self = this;
    swfobject.embedSWF(
      "http://www.youtube.com/v/" + videoId + "?enablejsapi=1",
      "video",
      "800",
      "450",
      "8",
      null,
      null,
      { allowScriptAccess: "always" },
      { id: "player" }
    );
    window.onYouTubePlayerReady = function() {
      self.player = document.getElementById("player");
      self.player.addEventListener("onStateChange", "onplayerStateChange");
    };
    window.onplayerStateChange = function(newState) {
      if (newState === 0 ) {
        self.play(self.videos.next());
      }
    };
  }
});

})();
