(function() {
  "use strict";
  window.PetaTube = {
    Model: {},
    Collection: {},
    View: {}
  };

  jQuery(function() {
    var PetaTube, match, pages, url, videos;
    PetaTube = window.PetaTube;
    videos = new PetaTube.Collection.Videos();
    new PetaTube.View.Search({
      videos: videos
    });
    new PetaTube.View.Video({
      videos: videos
    });
    match = window.location.search.match(/\?(https?.+)/);
    if (match) {
      url = match[1];
      videos.fetchByUrl(url);
    } else {
      pages = new PetaTube.Collection.Pages();
      new PetaTube.View.Popular({
        collection: pages
      });
      pages.fetch();
    }
    return $('.bookmarklet').powerTip({
      placement: 's'
    });
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.Model.HotPage = Backbone.Model.extend({
    petaURL: function() {
      var url;
      url = this.get('url');
      return "/?" + url;
    },
    thumbnailImagePath: function() {
      var thumbnailVideoId;
      thumbnailVideoId = this.get('thumbnailVideoId');
      return "http://i.ytimg.com/vi/" + thumbnailVideoId + "/default.jpg";
    }
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.Model.Video = Backbone.Model.extend({
    urlRoot: '/videos/'
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.Collection.Pages = Backbone.Collection.extend({
    model: PetaTube.Model.HotPage,
    fetch: function() {
      var _this = this;
      return $.ajax({
        url: "/popular",
        dataType: "json",
        data: {}
      }).done(function(data) {
        return _this.reset(data);
      });
    }
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.Collection.Videos = Backbone.Collection.extend({
    currentIndex: 0,
    model: PetaTube.Model.Video,
    fetchByUrl: function(url) {
      var _this = this;
      return $.ajax({
        url: "/videos/",
        dataType: "json",
        data: {
          url: url
        }
      }).done(function(data) {
        _this.currentIndex = 0;
        _this.title = data.title;
        _this.url = data.url;
        _this.reset(data.video_ids);
        return _this.trigger('change:title');
      });
    },
    current: function() {
      return this.at(this.currentIndex);
    },
    next: function() {
      ++this.currentIndex;
      if (this.currentIndex >= this.length) {
        return this.currentIndex = 0;
      }
    },
    prev: function() {
      --this.currentIndex;
      if (this.currentIndex < 0) {
        return this.currentIndex = this.length - 1;
      }
    },
    skip: function() {
      var removeId;
      removeId = this.current().id;
      this.next();
      this.remove(removeId);
      if (this.currentIndex !== 0) {
        return this.prev();
      }
    },
    shufflePlay: function() {
      this.currentIndex = 0;
      return this.reset(this.shuffle());
    }
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.View.Popular = Backbone.View.extend({
    el: "#hot",
    initialize: function() {
      return this.collection.on("reset", this.draw, this);
    },
    draw: function(pages) {
      var $list;
      $list = $('<ul>');
      pages.each(function(page) {
        var popular, tmpl;
        tmpl = $('#tmpl-hot-pages').html();
        popular = _.template(tmpl, {
          title: page.get('title'),
          petaURL: page.petaURL(),
          videoCount: page.get('videoCount'),
          thumbnailImagePath: page.thumbnailImagePath()
        });
        return $list.append(popular);
      });
      this.$el.append($list);
      return this.$el.fadeIn();
    }
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.View.Search = Backbone.View.extend({
    el: "#input-url",
    initialize: function(args) {
      this.videos = args.videos;
      return this.videos.on('change:title', this.showTitle, this);
    },
    events: {
      "submit form": "search"
    },
    search: function() {
      var url;
      url = this.$el.find("input[name='url']").val();
      if (url) {
        window.location.search = url;
      }
      return false;
    },
    showTitle: function() {
      return this.$el.find('#play-url').empty().append($('<span>').text("by ")).append($('<a>').attr('href', this.videos.url).text(this.videos.title)).append($('<span class="video_count">').text("(" + this.videos.length + "videos)"));
    }
  });

}).call(this);

(function() {
  "use strict";
  PetaTube.View.Video = Backbone.View.extend({
    player: null,
    el: "#play-video",
    initialize: function(args) {
      this.videos = args.videos;
      return this.videos.on("reset", this.play, this);
    },
    events: {
      "click #prev-button": "prev",
      "click #next-button": "next",
      "click #shuffle-button": "shuffle"
    },
    next: function() {
      this.videos.next();
      return this.play();
    },
    prev: function() {
      this.videos.prev();
      return this.play();
    },
    skip: function() {
      this.videos.skip();
      return this.play();
    },
    shuffle: function() {
      return this.videos.shufflePlay();
    },
    play: function() {
      var $panel, tmpl, video,
        _this = this;
      video = this.videos.current();
      if (video.get('title')) {
        this.$el.find("#video-info").text(video.get('title'));
        $('title').text(video.get('title') + "(PetaTube)");
      } else {
        video.fetch({
          success: function() {
            _this.$el.find("#video-info").text(video.get('title'));
            return $('title').text("" + (video.get('title')) + "(PetaTube)");
          }
        });
      }
      this.loadPlayer();
      tmpl = $('#tmpl-button').html();
      $panel = _.template(tmpl, {
        current: this.videos.currentIndex + 1,
        total: this.videos.length
      });
      this.$el.find("#video-panel").html($panel);
      return this.$el.show();
    },
    loadPlayer: function() {
      var firstScriptTag, tag, video,
        _this = this;
      video = this.videos.current();
      if (this.player) {
        return this.player.loadVideoById(video.id);
      }
      tag = document.createElement('script');
      tag.src = "//www.youtube.com/iframe_api";
      firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
      return window.onYouTubeIframeAPIReady = function() {
        return _this.player = new YT.Player('video', {
          height: '425',
          width: '760',
          videoId: video.id,
          events: {
            onReady: function() {},
            onStateChange: function(e) {
              var state;
              state = e.data;
              if (state === YT.PlayerState.ENDED) {
                return _this.next();
              }
            },
            onError: function() {
              return _this.skip();
            }
          }
        });
      };
    }
  });

}).call(this);

(function() {
  "use strict";


}).call(this);
