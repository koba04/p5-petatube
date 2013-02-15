/* this file is generated by concat task of grunt.js */
(function () {
  "use strict";

  window.PetaTube = {
    Model: {},
    Collection: {},
    View: {}
  };

  jQuery(function () {
    var PetaTube = window.PetaTube;

    var videos = new PetaTube.Collection.Videos();
    // initialize view
    new PetaTube.View.Search({
      videos: videos
    });
    new PetaTube.View.Video({
      videos: videos
    });

    var match = window.location.search.match(/\?(https?.+)/);
    if (match) {
      var url = match[1];
      videos.fetchByUrl(url);
    } else {
      // fetch hot page
      var hotPages = new PetaTube.Collection.HotPages();
      new PetaTube.View.HotPages({
        collection: hotPages
      });
      hotPages.fetch();
    }

  });

})();

(function () {
  "use strict";

  PetaTube.Model.HotPage = Backbone.Model.extend({
    petaURL: function () {
      return "/?" + this.get('url');
    },
    thumbnailImagePath: function () {
      return "http://i.ytimg.com/vi/" + this.get('thumbnailVideoId') + "/default.jpg";
    }
  });

})();

(function () {
  "use strict";

  PetaTube.Model.Video = Backbone.Model.extend({
    urlRoot: '/api/video'
  });

})();

(function () {
  "use strict";

  PetaTube.Collection.HotPages = Backbone.Collection.extend({
    model: PetaTube.Model.HotPage,
    fetch: function () {
      $.ajax({
        url: "/api/hot",
        dataType: "json",
        data: {}
      }).done($.proxy(function (data) {
        this.reset(data);
      }, this));
    }
  });

})();

(function () {
  "use strict";

  PetaTube.Collection.Videos = Backbone.Collection.extend({
    currentIndex: 0,
    model: PetaTube.Model.Video,
    fetchByUrl: function (url) {
      $.ajax({
        url: "/api/page",
        dataType: "json",
        data: { url: url }
      }).done($.proxy(function (data) {
        this.currentIndex = 0;
        this.title = data.title;
        this.url = data.url;
        /*jshint camelcase:false  */
        this.reset(data.video_ids);
        this.trigger('change:title');
      }, this));
    },
    // return current model
    current: function () {
      return this.at(this.currentIndex);
    },
    next: function () {
      ++this.currentIndex;
      if (this.currentIndex >= this.length) {
        this.currentIndex = 0;
      }
    },
    prev: function () {
      --this.currentIndex;
      if (this.currentIndex < 0) {
        this.currentIndex = this.length - 1;
      }
    },
    // remove can't play video
    skip: function () {
      var removeId = this.current().id;
      this.next();
      this.remove(removeId);
      if (this.currentIndex !== 0) {
        this.prev();
      }
    },
    shufflePlay: function () {
      this.currentIndex = 0;
      this.reset(this.shuffle());
    }
  });

})();

(function () {
  "use strict";

  PetaTube.View.HotPages = Backbone.View.extend({
    el: "#hot",
    initialize: function () {
      this.collection.on("reset", this.draw, this);
    },
    draw: function (pages) {
      var $list = $('<ul>');
      pages.each(function (page) {
        var tmpl = $('#tmpl-hot-pages').html();
        var hot = _.template(tmpl, {
          title:              page.get('title'),
          petaURL:            page.petaURL(),
          videoCount:         page.get('videoCount'),
          thumbnailImagePath: page.thumbnailImagePath()
        });
        $list.append(hot);
      });
      this.$el.append($list);
      this.$el.fadeIn();
    }
  });

})();

(function () {
  "use strict";

  PetaTube.View.Search = Backbone.View.extend({
    el: "#input-url",
    initialize: function (args) {
      this.videos = args.videos;
      this.videos.on('change:title', this.showTitle, this);
    },
    events: {
      "submit form": "search"
    },
    search: function () {
      var url = this.$el.find("input[name='url']").val();
      if (url) {
        // replace location.search
        window.location.search = url;
      }
      return false;
    },
    showTitle: function () {
      // TODO template
      this.$el.find('#play-url').empty().append($('<span>').text("by "))
        .append($('<a>').attr('href', this.videos.url).text(this.videos.title))
        .append($('<span class="video_count">').text('(' + this.videos.length + 'videos)'));
    }
  });

})();

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
          height: '450',
          width: '800',
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

(function () {


})();
