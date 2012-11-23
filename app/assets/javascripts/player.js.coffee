//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require twitter/bootstrap/transition
//= require twitter/bootstrap/modal
//= require libraries/underscore-min
//= require libraries/backbone-min

//= require namespaces
//= require soundcloud

//= require player/errors/collections
//= require player/errors/variables

//= require player/models/search_result
//= require player/models/search_result_collection
//= require player/models/playlist
//= require player/models/playlist_collection

//= require player/views/search_result
//= require player/views/search_panel
//= require player/views/playlist_tab
//= require player/views/playlists_panel

//= require player/views/app


$ ->     
  window.APP = new CloudAmp.Views.App
  
  
