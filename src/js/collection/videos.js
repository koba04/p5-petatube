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
