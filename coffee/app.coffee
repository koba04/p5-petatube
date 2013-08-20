"use strict"

window.PetaTube =
  Model: {}
  Collection: {}
  View: {}

jQuery ->
  PetaTube = window.PetaTube
  videos = new PetaTube.Collection.Videos()
  # initialize view
  new PetaTube.View.Search
    videos: videos

  new PetaTube.View.Video
    videos: videos

  match = window.location.search.match /\?(https?.+)/
  if match
    url = match[1]
    videos.fetchByUrl url
  else
    # fetch hot page
    hotPages = new PetaTube.Collection.HotPages()
    new PetaTube.View.HotPages
      collection: hotPages
    hotPages.fetch()

  # tooltip
  $('.bookmarklet').powerTip
    placement: 's'

