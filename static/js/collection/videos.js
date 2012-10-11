(function() {

PetaTube.Collection.Videos = Backbone.Collection.extend({
  currentIndex: 0,
  model: PetaTube.Model.Video,
  fetchByUrl: function(url) {
    var self = this;
    $.ajax({
      url: "/api/page",
      dataType: "json",
      data: { url: url }
    }).done(function(data) {
      self.currentIndex = 0;
      self.title = data.title;
      self.url = data.url;
      self.reset(data.video_ids);
      self.trigger('change:title');
    });
  },
  // return current model
  current: function() {
    return this.at(this.currentIndex);
  },
  next: function() {
    ++this.currentIndex;
    if ( this.currentIndex >= this.length ) {
      this.currentIndex = 0;
    }
  },
  prev: function() {
    --this.currentIndex;
    if ( this.currentIndex < 0 ) {
      this.currentIndex = this.length - 1;
    }
  },
  // remove can't play video
  skip: function() {
    var removeId = this.current().id;
    this.next();
    this.remove(removeId);
    if ( this.currentIndex !== 0 ) {
      this.prev();
    }
  }
});


})();
