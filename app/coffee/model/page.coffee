"use strict";

PetaTube.Model.HotPage = Backbone.Model.extend
  petaURL: ->
    url = @get 'url'
    return "/?#{url}"

  thumbnailImagePath: ->
    thumbnailVideoId = @get 'thumbnailVideoId'
    return "http://i.ytimg.com/vi/#{thumbnailVideoId}/default.jpg"
