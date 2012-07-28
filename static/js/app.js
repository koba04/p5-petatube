window.PetaTube = {
  Model: {},
  Collection: {},
  View: {}
};

jQuery(function($) {

var match = window.location.search.match(/\?(https?:\/\/.+)/);
if ( match ) {
  var url = match[1];
  $.ajax({
    url: '/api/site',
    dataType: "json",
    data: { url: url }
  }).done(function(data) {
    console.dir(data);
  }).fail(function() {
    console.log("error");
  });
}

});
