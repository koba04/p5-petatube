"use strict";

PetaTube.View.Video = Backbone.View.extend
  player: null
  el: "#play-video"
  initialize: (args) ->
    @videos = args.videos
    @videos.on "reset", @play, @

  events:
    "click #prev-button": "prev"
    "click #next-button": "next"
    "click #shuffle-button": "shuffle"

  # play next video
  next: ->
    @videos.next()
    @play()

  # play prev video
  prev: ->
    @videos.prev()
    @play()

  # skip can't play video
  skip: ->
    @videos.skip()
    @play()

  shuffle: ->
    @videos.shufflePlay()

  # play current video
  play : ->
    video = @videos.current()
    if video.get('title')
      @$el.find("#video-info").text(video.get('title'))
      $('title').text(video.get('title') + "(PetaTube)")
    else
      video.fetch
        success: =>
          @$el.find("#video-info").text video.get('title')
          $('title').text "#{video.get('title')}(PetaTube)"

    @loadPlayer()
    tmpl = $('#tmpl-button').html()
    $panel = _.template tmpl,
      current: @videos.currentIndex + 1
      total: @videos.length

    @$el.find("#video-panel").html $panel
    @$el.show()

  loadPlayer: ->
    video = @videos.current()
    # already create video player
    if @player
      return @player.loadVideoById video.id

    # https://developers.google.com/youtube/iframe_api_reference
    tag = document.createElement 'script'
    tag.src = "//www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag
    window.onYouTubeIframeAPIReady = =>
      @player = new YT.Player 'video',
        height: '425'
        width: '760'
        videoId: video.id
        events:
          onReady: ->
            # doesn't play video on iphone.
            # e.target.playVideo()
          onStateChange: (e) =>
            state = e.data
            if state is YT.PlayerState.ENDED
              @next()

          onError: =>
            @skip()

