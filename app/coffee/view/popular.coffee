"use strict"

PetaTube.View.Popular = Backbone.View.extend
  el: "#hot"
  initialize: ->
    @collection.on "reset", @draw, @

  draw: (pages) ->
    $list = $('<ul>')
    pages.each (page) ->
      tmpl = $('#tmpl-hot-pages').html()
      popular = _.template(tmpl,
        title:              page.get 'title'
        petaURL:            page.petaURL(),
        videoCount:         page.get 'videoCount'
        thumbnailImagePath: page.thumbnailImagePath()
      )
      $list.append popular

    @$el.append $list
    @$el.fadeIn()
