$ ->
  class CloudAmp.Views.PlaylistsPanel extends Backbone.View
    el: $ "#panel_playlists"
    
    initialize: ->
      @playlist_collection = new CloudAmp.Models.PlaylistCollection
      @playlist_collection.on 'reset', @render_all_playlists
      @playlist_collection.on 'add',   @render_one_playlist
      
    events:
      "click #modal_new_playlist_submit" : "create_playlist"
      "click #new_playlist_button"       : "show_new_playlist_modal"
      
    
    bootstrap: (initial_data) ->
      @playlist_collection.reset initial_data
      

    render_one_playlist: (playlist) =>
      view   = new CloudAmp.Views.PlaylistTab({ model: playlist })
      output = view.render().el
      @$("#panel_playlists_tabs ul").append output
      $(output).children("*[rel=tooltip]").tooltip()
      
      
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

     
