(function() {
"use strict";

PetaTube.Model.HotPage = Backbone.Model.extend({
  petaURL: function() {
    return "/?" + this.get('url');
  }
});

})();
