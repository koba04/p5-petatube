(function() {

PetaTube.View.Search = Backbone.View.extend({
  el: "#input-url",
  initialize: function(args) {
    this.videos = args.videos;
  },
  events: {
    "submit form": "search"
  },
  search: function() {
    var url = this.$el.find("input[name='url']").val();
    if ( url ) {
      this.videos.fetchByUrl(url);
    }
    return false;
  }
});

})();
