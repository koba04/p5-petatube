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
