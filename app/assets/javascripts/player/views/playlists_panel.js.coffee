$ ->
  class CloudAmp.Views.PlaylistsPanel extends Backbone.View
    el: $ "#panel_playlists"
    
    initialize: ->
      @playlist_collection = new CloudAmp.Models.PlaylistCollection
      @playlist_collection.on 'reset',  @render_all_playlists
      @playlist_collection.on 'add',    @render_one_playlist
      @playlist_collection.on 'add',    @update_remove_playlist_button
      @playlist_collection.on 'remove', @cleanup_playlist
      @playlist_collection.on 'remove', @update_remove_playlist_button

      @playlist_views = {}

      
    events:
      "click       #modal_new_playlist_submit"    : "create_playlist"
      "click       #modal_edit_playlist_submit"   : "update_playlist"
      "click       #modal_remove_playlist_submit" : "destroy_playlist"
      "click       #new_playlist_button"          : "show_new_playlist_modal"
      "click       #edit_playlist_button"         : "show_edit_playlist_modal"
      "click       #remove_playlist_button"       : "show_remove_playlist_modal"
      "shown       a[data-toggle='tab']"          : "on_tab_changed"
      "sortreceive .playlist-dragndrop"           : "on_track_dropped"
      
    
    bootstrap: (initial_data) ->
      @playlist_collection.reset initial_data
      @playlist_collection.each (playlist) =>
        playlist.tracks.reset playlist.get("tracks")
        playlist.unset("tracks")
      
      
    on_tab_changed: (event) ->
      @current_playlist = $(event.target).parent().backboneView().model
      

    render_one_playlist: (playlist) =>
      # Render playlist's tab
      tab_view   = new CloudAmp.Views.PlaylistTab({ model: playlist })
      tab_output = tab_view.render().el

      # Append playlist's tab to DOM
      @$("#panel_playlists_tabs ul").append tab_output


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
      
      @select_first_playlist()
      @update_remove_playlist_button()


    cleanup_playlist: (playlist, collection) =>
      playlist.destroy()
      delete @playlist_views[playlist.id]
      @select_first_playlist()


    update_remove_playlist_button: =>
      if @playlist_collection.size() == 1
        @$("#remove_playlist_button").attr("disabled", true)
        @$("#remove_playlist_button").attr("data-original-title", "Unable to remove last playlist")
      else
        @$("#remove_playlist_button").attr("disabled", false)
        @$("#remove_playlist_button").attr("data-original-title", "Remove this playlist")


    select_first_playlist: =>
      @$("#panel_playlists_tabs a[data-toggle=tab]:first").tab("show")
    
    
    
    show_new_playlist_modal: ->
      $("#modal_new_playlist button").attr "disabled", false
      $("#modal_new_playlist_field_title").val ""
      $("#modal_new_playlist_field_description").val ""
      $("#modal_new_playlist").modal 'show' 
        

    show_edit_playlist_modal: ->
      $("#modal_edit_playlist button").attr "disabled", false
      $("#modal_edit_playlist_field_title").val @current_playlist.get("title")
      $("#modal_edit_playlist_field_description").val @current_playlist.get("description")
      $("#modal_edit_playlist").modal 'show' 

      
    show_remove_playlist_modal: =>
      return if @$("#remove_playlist_button").attr("disabled") == "disabled"
      
      $("#modal_remove_playlist button").attr "disabled", false
      $("#modal_remove_playlist_title").text @current_playlist.get("title")
      $("#modal_remove_playlist").modal 'show' 
      


    validate_playlist_form: (modal_type) ->
      $("#modal_" + modal_type + "_playlist_error_cannot_save").hide()
      $("#modal_" + modal_type + "_playlist_error_title_empty").hide()
      $("#modal_" + modal_type + "_playlist_label_title").removeClass "errorneous"
      $("#modal_" + modal_type + "_playlist_field_title").removeClass "errorneous"

      if $("#modal_" + modal_type + "_playlist_field_title").val().trim() == ""
        $("#modal_" + modal_type + "_playlist_error_title_empty").fadeIn()
        $("#modal_" + modal_type + "_playlist_label_title").addClass "errorneous"
        $("#modal_" + modal_type + "_playlist_field_title").addClass "errorneous"
        
        return false
      else
        $("#modal_" + modal_type + "_playlist button").attr "disabled", true
        return true



    create_playlist: ->
      return unless @validate_playlist_form("new")
        
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


    update_playlist: =>
      return unless @validate_playlist_form("edit")

      @current_playlist.set("title", $("#modal_edit_playlist_field_title").val().trim())
      @current_playlist.set("description", $("#modal_edit_playlist_field_description").val().trim())
      
      @current_playlist.save {}, 
        success: (model, response, options) =>
          $("#modal_edit_playlist").modal 'hide'

        error: (model, response, options) =>
          $("#modal_edit_playlist_error_cannot_save").fadeIn()
          $("#modal_edit_playlist button").attr "disabled", false


    destroy_playlist: =>
      @playlist_collection.remove @current_playlist
      $("#modal_remove_playlist button").attr "disabled", true
      $("#modal_remove_playlist").modal 'hide' 

     
    # Handles receiving a track drag'n'dropped from search results.
    #
    # @param event jQuery event
    # @param ui object that describes this drag'n'drop action, please refer to 
    #        http://api.jqueryui.com/sortable/#event-receive for more information
    on_track_dropped: (event, ui) ->
      # Find model associated with dragged DOM element
      model = ui.item.backboneView().model
      
      # Remove it model from search results collection
      model.collection.remove model
      
      # Find ID of playlist that was used to drop the track and add it to the model
      playlist_id = parseInt(ui.item.closest(".playlist-container").attr("playlist_id"))
      model.set "playlist_id", playlist_id
      
      # Find tracks collection associated with this playlist and add new track
      @playlist_views[playlist_id]["container"].model.tracks.add model
      
      
