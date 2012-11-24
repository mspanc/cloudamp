$ ->
  class CloudAmp.Views.PlaylistsPanel extends Backbone.View
    el: $ "#panel_playlists"
    
    initialize: ->
      @playlist_collection = new CloudAmp.Models.PlaylistCollection
      @playlist_collection.on 'reset', @render_all_playlists
      @playlist_collection.on 'add',   @render_one_playlist
      
    events:
      "click       #modal_new_playlist_submit" : "create_playlist"
      "click       #new_playlist_button"       : "show_new_playlist_modal"
      "sortreceive .playlist-dragndrop"        : "receive_track"
      
    
    bootstrap: (initial_data) ->
      @playlist_collection.reset initial_data
      

    render_one_playlist: (playlist) =>
      tab_view   = new CloudAmp.Views.PlaylistTab({ model: playlist })
      tab_output = tab_view.render().el
      @$("#panel_playlists_tabs ul").append tab_output
      $(tab_output).children("*[rel=tooltip]").tooltip()

      container_view   = new CloudAmp.Views.PlaylistContainer({ model: playlist })
      container_output = container_view.render().el
      @$("#panel_playlists_contents").append container_output
      
      
    render_all_playlists: (playlists) =>
      playlists.each (playlist) =>
        @render_one_playlist playlist
      
      @$("#panel_playlists_tabs a[data-toggle=tab]:first").tab("show")

    
    show_new_playlist_modal: () ->
      @$("#modal_new_playlist button").attr "disabled", false
      @$("#modal_new_playlist_field_title").val ""
      @$("#modal_new_playlist_field_description").val ""
      @$("#modal_new_playlist").modal 'show' 
        
        
    create_playlist: () ->
      @$("#modal_new_playlist_error_cannot_save").hide()
      @$("#modal_new_playlist_error_title_empty").hide()
      @$("#modal_new_playlist_label_title").removeClass "errorneous"
      @$("#modal_new_playlist_field_title").removeClass "errorneous"
      
      if $("#modal_new_playlist_field_title").val().trim() == ""
        @$("#modal_new_playlist_error_title_empty").fadeIn()
        @$("#modal_new_playlist_label_title").addClass "errorneous"
        @$("#modal_new_playlist_field_title").addClass "errorneous"

      else
        @$("#modal_new_playlist button").attr "disabled", true
        
        playlist = new CloudAmp.Models.Playlist 
          title : $("#modal_new_playlist_field_title").val().trim(), 
          description : $("#modal_new_playlist_field_description").val().trim()
          
        playlist.save {}, 
          success: (model, response, options) =>
            @playlist_collection.add playlist
            @$("#modal_new_playlist").modal 'hide'

          error: (model, response, options) =>
            @$("#modal_new_playlist_error_cannot_save").fadeIn()
            @$("#modal_new_playlist button").attr "disabled", false

     
    receive_track: (event, ui) ->
      console.log "Got track!"
      console.log event
      console.log ui
      console.log ui.item
 
