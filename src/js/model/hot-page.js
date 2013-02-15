(function () {
  "use strict";

  PetaTube.Model.HotPage = Backbone.Model.extend({
    petaURL: function () {
      return "/?" + this.get('url');
    },
    thumbnailImagePath: function () {
      return "http://i.ytimg.com/vi/" + this.get('thumbnailVideoId') + "/default.jpg";
    }
  });

})();
