window.PetaTube = {
  Model: {},
  Collection: {},
  View: {}
};

jQuery(function($) {
"use strict";

var videos = new PetaTube.Collection.Videos();
// initialize view
new PetaTube.View.Search({
  videos: videos
});
new PetaTube.View.Video({
  videos: videos
});
//new PetaTube.View.Videos({
//  collection: videos
//});

var match = window.location.search.match(/\?(https?.+)/);
if ( match ) {
  var url = match[1];
  videos.fetchByUrl(url);
}

});
