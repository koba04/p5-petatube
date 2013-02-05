(function () {
  "use strict";

  PetaTube.Collection.HotPages = Backbone.Collection.extend({
    model: PetaTube.Model.HotPage,
    fetch: function () {
      var self = this;
      $.ajax({
        url: "/api/hot",
        dataType: "json",
        data: {}
      }).done(function (data) {
        self.reset(data);
      });
    }
  });

})();
