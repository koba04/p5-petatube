(function() {

PetaTube.Collection.Videos = Backbone.Collection.extend({
  currentIndex: 0,
  model: PetaTube.Model.Video,
  fetchByUrl: function(url) {
    var self = this;
    $.ajax({
      url: "/api/site",
      dataType: "json",
      data: { url: url }
    }).done(function(data) {
      self.currentIndex = 0;
      console.dir(data);
      self.reset(data.video_ids);
    });
  },
  getCurrentModel: function() {
    return this.at(this.currentIndex);
  },
  next: function() {
    ++this.currentIndex;
    if ( this.currentIndex >= this.length ) {
      this.currentIndex = 0;
    }
    var video = this.getCurrentModel();
    if ( video ) {
      return video.id;
    }
  },
  prev: function() {
    --this.currentIndex;
    if ( this.currentIndex < 0 ) {
      this.currentIndex = this.length;
    }
    var video = this.getCurrentModel();
    if ( video ) {
      return video.id;
    }
  }
});


})();
