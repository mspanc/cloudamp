$ ->
  class CloudAmp.Views.App extends Backbone.View
    el: $ "#app"
    
    initialize: ->
      @search_panel_view    = new CloudAmp.Views.SearchPanel
      @playlists_panel_view = new CloudAmp.Views.PlaylistsPanel
    
    
    bootstrap_playlists: (playlists) ->
      @playlists_panel_view.bootstrap(playlists)
