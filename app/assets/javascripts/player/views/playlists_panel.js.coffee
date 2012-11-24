$ ->
  class CloudAmp.Views.PlaylistsPanel extends Backbone.View
    el: $ "#panel_playlists"
    
    initialize: ->
      @playlist_collection = new CloudAmp.Models.PlaylistCollection
      @playlist_collection.on 'reset', @render_all_playlists
      @playlist_collection.on 'add',   @render_one_playlist

      @playlist_views = {}

      
    events:
      "click       #modal_new_playlist_submit" : "create_playlist"
      "click       #new_playlist_button"       : "show_new_playlist_modal"
      "sortreceive .playlist-dragndrop"        : "receive_track"
      
    
    bootstrap: (initial_data) ->
      @playlist_collection.reset initial_data
      @playlist_collection.each (playlist) =>
        playlist.tracks.reset playlist.get("tracks")
        playlist.unset("tracks")
      

    render_one_playlist: (playlist) =>
      # Render playlist's tab
      tab_view   = new CloudAmp.Views.PlaylistTab({ model: playlist })
      tab_output = tab_view.render().el

      # Append playlist's tab to DOM
      @$("#panel_playlists_tabs ul").append tab_output

      # Enable tooltips with playlists' descriptions
      $(tab_output).children("a[rel=tooltip]").tooltip()


      # Render playlist contents's container
      container_view   = new CloudAmp.Views.PlaylistContainer({ model: playlist })
      container_output = container_view.render().el

      # Append playlist contents's to DOM
      @$("#panel_playlists_contents").append container_output

      # Enable drag'n'drop
      $(container_output).find("tbody")
        .disableSelection()
        .sortable
          connectWith : ".playlist-dragndrop"
          items       : ">*:not(.message-empty)"
          appendTo    : "#app"
          helper      : "clone"
          
      
      # Show message about empty playlist if it is empty
      container_view.update_empty_message()
        
      

      # Store references 
      @playlist_views[playlist.id] = 
        "tab"       : tab_view
        "container" : container_view
        
      
    render_all_playlists: (playlists) =>
      playlists.each (playlist) =>
        @render_one_playlist playlist
      
      @$("#panel_playlists_tabs a[data-toggle=tab]:first").tab("show")

    
    show_new_playlist_modal: () ->
      $("#modal_new_playlist button").attr "disabled", false
      $("#modal_new_playlist_field_title").val ""
      $("#modal_new_playlist_field_description").val ""
      $("#modal_new_playlist").modal 'show' 
        
        
    create_playlist: () ->
      $("#modal_new_playlist_error_cannot_save").hide()
      $("#modal_new_playlist_error_title_empty").hide()
      $("#modal_new_playlist_label_title").removeClass "errorneous"
      $("#modal_new_playlist_field_title").removeClass "errorneous"
      
      if $("#modal_new_playlist_field_title").val().trim() == ""
        $("#modal_new_playlist_error_title_empty").fadeIn()
        $("#modal_new_playlist_label_title").addClass "errorneous"
        $("#modal_new_playlist_field_title").addClass "errorneous"

      else
        $("#modal_new_playlist button").attr "disabled", true
        
        playlist = new CloudAmp.Models.Playlist 
          title : $("#modal_new_playlist_field_title").val().trim(), 
          description : $("#modal_new_playlist_field_description").val().trim()
          
        playlist.save {}, 
          success: (model, response, options) =>
            @playlist_collection.add playlist
            $("#modal_new_playlist").modal 'hide'

          error: (model, response, options) =>
            $("#modal_new_playlist_error_cannot_save").fadeIn()
            $("#modal_new_playlist button").attr "disabled", false

     
    # Handles receiving a track drag'n'dropped from search results.
    #
    # @param event jQuery event
    # @param ui object that describes this drag'n'drop action, please refer to 
    #        http://api.jqueryui.com/sortable/#event-receive for more information
    receive_track: (event, ui) ->
      # Find model associated with dragged DOM element
      model = ui.item.backboneView().model
      
      # Remove it model from search results collection
      model.collection.remove model
      
      # Find ID of playlist that was used to drop the track and add it to the model
      playlist_id = parseInt(ui.item.closest(".playlist-container").attr("playlist_id"))
      model.set "playlist_id", playlist_id
      
      # Find tracks collection associated with this playlist and add new track
      @playlist_views[playlist_id]["container"].model.tracks.add model
      
      
