"use strict"

PetaTube.Collection.Pages = Backbone.Collection.extend
  model: PetaTube.Model.HotPage
  fetch: ->
    $.ajax(
      url: "/popular"
      dataType: "json"
      data: {}
    ).done( (data) =>
      @reset data
    )

