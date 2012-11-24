//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require twitter/bootstrap/transition
//= require twitter/bootstrap/modal
//= require twitter/bootstrap/tab
//= require twitter/bootstrap/tooltip
//= require libraries/underscore-min
//= require libraries/backbone-min

//= require csrf
//= require namespaces
//= require soundcloud

//= require player/errors/collections
//= require player/errors/variables

//= require player/models/track
//= require player/models/track_collection
//= require player/models/search_result_collection
//= require player/models/playlist
//= require player/models/playlist_collection

//= require player/views/track
//= require player/views/playlist_tab
//= require player/views/playlist_container

//= require player/views/search_panel
//= require player/views/playlists_panel

//= require player/views/app


$ ->
  window.APP = new CloudAmp.Views.App
  
  $("*[rel=tooltip]").tooltip()
  
  
