(function() {

PetaTube.View.HotPages = Backbone.View.extend({
  el: "#hot",
  initialize: function() {
    this.collection.on("reset", this.draw, this);
  },
  draw: function(pages) {
    var $list = $('<ul>');
    pages.each(function(page) {
      var $li = $('<li>');
      var $a = $('<a>').attr('href', page.petaURL()).text(page.get('title'));
      $li.append($a);
      $list.append($li);
    });
    this.$el.append($list);
    this.$el.fadeIn();
  }
});



})();
