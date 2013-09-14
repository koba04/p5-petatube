"use strict"

PetaTube.View.Search = Backbone.View.extend
  el: "#input-url"
  initialize: (args) ->
    @videos = args.videos
    @videos.on 'change:title', @showTitle, @

  events:
    "submit form": "search"

  search: ->
    url = @$el.find("input[name='url']").val()
    if url
      # replace location.search
      window.location.search = url
    false

  showTitle: ->
    # TODO template
    @$el.find('#play-url').empty().append($('<span>').text("by "))
      .append($('<a>').attr('href', @videos.url).text(@videos.title))
      .append($('<span class="video_count">').text("(#{@videos.length}videos)"))
