(function() {

PetaTube.View.Search = Backbone.View.extend({
  el: "#input-url",
  initialize: function(args) {
    this.videos = args.videos;
    this.videos.on('change:title', this.showTitle, this);
  },
  events: {
    "submit form": "search"
  },
  search: function() {
    var url = this.$el.find("input[name='url']").val();
    if ( url ) {
      // replace location.search
      window.location.search = url;
    }
    return false;
  },
  showTitle: function(data) {
    // TODO template
    this.$el.find('#play-url').empty().append($('<span>').text("by "))
      .append($('<a>').attr('href', this.videos.url).text(this.videos.title))
      .append($('<span class="video_count">').text('(' + this.videos.length + 'videos)'));
  }
});

})();
