$ ->
  class CloudAmp.Views.PlaylistsPanel extends Backbone.View
    el: $ "#panel_playlists"
    
    initialize: ->
      @playlist_collection = new CloudAmp.Models.PlaylistCollection
      @playlist_collection.on 'reset', @render_all_playlists
      
    
    bootstrap: (initial_data) ->
      @playlist_collection.reset initial_data
      
    render_all_playlists: (playlists) ->
      playlists.each (playlist) ->
        view = new CloudAmp.Views.PlaylistTab({ model: playlist });
        @$("#panel_playlists_tabs ul").append(view.render().el);
