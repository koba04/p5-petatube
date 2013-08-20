"use strict";

PetaTube.Collection.Videos = Backbone.Collection.extend
  currentIndex: 0
  model: PetaTube.Model.Video
  fetchByUrl: (url) ->
    $.ajax(
      url: "/videos/"
      dataType: "json"
      data:
        url: url
    ).done( (data) =>
      @currentIndex = 0
      @title = data.title
      @url = data.url
      @reset data.video_ids
      @trigger 'change:title'
    )

  # return current model
  current: ->
    @at @currentIndex

  next: ->
    ++@currentIndex
    if @currentIndex >= @length
      @currentIndex = 0

  prev: ->
    --@currentIndex
    if @currentIndex < 0
      @currentIndex = @length - 1

  # remove can't play video
  skip: ->
    removeId = @current().id
    @next()
    @remove removeId
    if @currentIndex != 0
      @prev()

  shufflePlay: ->
    @currentIndex = 0
    @reset @shuffle()

