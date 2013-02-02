(function() {
"use strict";

PetaTube.View.HotPages = Backbone.View.extend({
  el: "#hot",
  initialize: function() {
    this.collection.on("reset", this.draw, this);
  },
  draw: function(pages) {
    var $list = $('<ul>');
    pages.each(function(page) {
      // TODO template
      var $li = $('<li>');
      var $a = $('<a>').attr('href', page.petaURL()).text(page.get('title'));
      var $span = $('<span class="video_count">').text('(' + page.get('video_count') + 'videos)');
      $li.append($a).append($span);
      $list.append($li);
    });
    this.$el.append($list);
    this.$el.fadeIn();
  }
});



})();
