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
