(function () {
  "use strict";

  PetaTube.Collection.HotPages = Backbone.Collection.extend({
    model: PetaTube.Model.HotPage,
    fetch: function () {
      $.ajax({
        url: "/api/hot",
        dataType: "json",
        data: {}
      }).done($.proxy(function (data) {
        this.reset(data);
      }, this));
    }
  });

})();
