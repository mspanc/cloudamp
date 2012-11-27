# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Playlist panel view.
  # 
  # It is mostly responsible for:
  # * handling playlist add/edit/remove buttons and modals,
  # * handling child views for playlist tabs and containers.
  #
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
      
    
    # This function is intended to be called with pregenerated data that
    # come from Rails app database (serialized as JSON).
    #
    # The data structure should be like this:
    #
    # [
    #   {"description": "123", 
    #    "id"     : 1, 
    #    "title"  : "123", 
    #    "tracks" : [
    #      { "artwork_url" : "http://i1.sndcdn.com/xyz",
    #        "duration"    : "00:03:31",
    #        "id"          : 45,
    #        "title"       : "The Stock Holders - Nebulous",
    #        "track_url"   : "http://api.soundcloud.com/tracks/58725589" }
    #     ]
    #   }
    # ]
    #
    # It is just an array of hashes, which are attributes of Playlist model,
    # with nested attributes of Track model referenced with key "tracks".
    #
    # @param initial_data initial playlists data
    bootstrap: (initial_data) ->
      @playlist_collection.reset initial_data
      @playlist_collection.each (playlist) =>
        playlist.tracks.reset playlist.get("tracks")
        playlist.unset("tracks")
      

    # Handles tab changes and stores current tab.
    #
    # @param event mouse event associated with the change
    on_tab_changed: (event) ->
      @current_playlist = $(event.target).parent().backboneView().model
      

    # Renders one playlists.
    #
    # In fact it means rendering two views: one for tab, second for playlist
    # container.
    #
    # @param playlist Playlist model to render
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
      CloudAmp.Helpers.DragNDrop.initialize_dragndrop_playlist_container $(container_output).find("tbody")

      # Show message about empty playlist if it is empty
      container_view.update_empty_message()

      # Store references 
      @playlist_views[playlist.id] = 
        "tab"       : tab_view
        "container" : container_view
        


    # Renders all playlists.
    #
    # @param playlist Playlists collection to render
    render_all_playlists: (playlists) =>
      playlists.each (playlist) =>
        @render_one_playlist playlist
      
      @select_first_playlist()
      @update_remove_playlist_button()


    # Cleanup playlist view.
    #
    # @param playlist Playlist model to cleanup
    # @param collection parent collection of the model
    cleanup_playlist: (playlist, collection) =>
      playlist.destroy()
      delete @playlist_views[playlist.id]
      @select_first_playlist()


    # Enables or disables remove playlist button when necessary
    update_remove_playlist_button: =>
      if @playlist_collection.size() == 1
        @$("#remove_playlist_button").attr("disabled", true)
        @$("#remove_playlist_button").attr("data-original-title", "Unable to remove last playlist")
      else
        @$("#remove_playlist_button").attr("disabled", false)
        @$("#remove_playlist_button").attr("data-original-title", "Remove this playlist")


    # Selects first tab
    select_first_playlist: =>
      @$("#panel_playlists_tabs a[data-toggle=tab]:first").tab("show")
    
    
    
    # Shows new playlist modal and resets its state
    show_new_playlist_modal: ->
      $("#modal_new_playlist button").attr "disabled", false
      $("#modal_new_playlist_field_title").val ""
      $("#modal_new_playlist_field_description").val ""
      $("#modal_new_playlist").modal 'show' 
        

    # Shows edit playlist modal and fills its fields with data from currently
    # selected playlist
    show_edit_playlist_modal: ->
      $("#modal_edit_playlist button").attr "disabled", false
      $("#modal_edit_playlist_field_title").val @current_playlist.get("title")
      $("#modal_edit_playlist_field_description").val @current_playlist.get("description")
      $("#modal_edit_playlist").modal 'show' 

      
    # Shows remove playlist modal and resets its state
    show_remove_playlist_modal: =>
      return if @$("#remove_playlist_button").attr("disabled") == "disabled"
      
      $("#modal_remove_playlist button").attr "disabled", false
      $("#modal_remove_playlist_title").text @current_playlist.get("title")
      $("#modal_remove_playlist").modal 'show' 
      


    # Helper function for validating playlist new/edit forms on modals.
    #
    # Prevents from saving changes if fields contain incorrect values.
    # Shows errors if necessary.
    #
    # @param modal_type "new" or "edit"
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


    # Handles new playlist creation process invoked by new playlist modal.
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



    # Handles playlist update process invoked by edit playlist modal.
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


    # Handles playlist removal process invoked by remove playlist modal.
    destroy_playlist: =>
      @playlist_collection.remove @current_playlist
      $("#modal_remove_playlist button").attr "disabled", true
      $("#modal_remove_playlist").modal 'hide' 

     

      
      
