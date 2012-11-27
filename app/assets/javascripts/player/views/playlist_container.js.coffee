# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Playlist container view, which is main playlist view visible to the user
  # (track list).
  #
  # It handles a few aspects of Playlist lifecycle:
  #  * rendering view of track list,
  #  * initializing rendering children tracks,
  #  * synchronizing tracks with the Rails backend when they get added/removed,
  #  * periodically synchronizing tracks positions within playlist with 
  #    the Rails backend.
  #
  class CloudAmp.Views.PlaylistContainer extends Backbone.View
    template   : _.template($('#playlist-container-template').html()),
    tagName    : "div"
    className  : "tab-pane playlist-container"
    
    # Used by tab hooks
    id         : =>
      "playlist" + @model.get("id")

    # Used by drag'n'drop lookup
    attributes : =>
      "playlist_id" : @model.get("id")
    
    events:
      "sortreceive .playlist-dragndrop"  : "on_track_dropped"
      
    
    initialize: ->
      @model.on         "destroy", @clean
      @model.tracks.on  "reset",   @render_all_tracks
      @model.tracks.on  "reset",   @update_empty_message
      @model.tracks.on  "add",     @update_empty_message
      @model.tracks.on  "add",     @store
      @model.tracks.on  "remove",  @update_empty_message

      # Setup periodic updates of track positions. Randomize interval in range
      # of 10..19 seconds in order to avoid the case in which multiple playlists
      # of one user get updated at the same time and server is overloaded.
      @store_positions_timeout = (10 + Math.round(Math.random() * 10)) * 1000
      @store_positions_interval =   setInterval(@store_positions, @store_positions_timeout)
      
    teardown: ->
      @model.off        "destroy", @clean
      @model.tracks.off "reset",   @render_all_tracks
      @model.tracks.off "reset",   @update_empty_message
      @model.tracks.off "add",     @update_empty_message
      @model.tracks.off "add",     @store
      @model.tracks.off "remove",  @update_empty_message
      
      clearInterval(@store_positions_interval)
    
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      return @
    
    
    # Cleanup myself.
    #
    # If I am the only track, hide the player widget.
    clean: =>
      if @$(".track.playing").length != 0 or @$(".track.paused").length != 0
        window.APP.hide_player_widget()
        
      @remove()


    # Renders one track
    #
    # @param track Track model to be rendered in the playlist track list
    render_one_track: (track) =>
      view   = new CloudAmp.Views.Track({ model: track });
      output = view.render().el
      @$("tbody").append(output);

      
    # Renders many tracks
    #
    # @param tracks Track model collection to be rendered in the playlist track list
    render_all_tracks: (tracks) =>
      tracks.each (track) =>
        @render_one_track track

    
    # Display or hides "this playlist is empty" message when necessary.
    update_empty_message: =>
      if @model.tracks.size() == 0  
        @$(".message-empty").show()
      else
        @$(".message-empty").hide()
      
    
    # Sends atomic update about track positions. We are not using standard 
    # Backbone.js sync methods because:
    #  * track position can happen quite often and updating DB each time
    #    would be an overkill,
    #  * standard method needs for instance 2 requests when 2 tracks get swapped,
    #    one of the requests can fail and this procedure becomes no longer atomic
    store_positions: =>
      positions = []

      @$(".track").each (i, element) -> 
        positions.push $(element).backboneView().model.id
      
      $.ajax
        data :
          positions : positions
        dataType    : "json"
        timeout     : @store_positions_timeout
        type        : "POST"
        url         : "/playlists/" + @model.id + "/track_positions"
     

    # Ensures that every track get saved after its added. Displays error modal
    # in case of error
    store: (model, collection) => 
      model.save
        error: =>
          $("#modal_track_save_error").modal 'show'
          
          
    # Handles receiving a track drag'n'dropped from search results.
    #
    # @param event jQuery event
    # @param ui object that describes this drag'n'drop action, please refer to 
    #        http://api.jqueryui.com/sortable/#event-receive for more information
    on_track_dropped: (event, ui) =>
      # Find model associated with dragged DOM element
      model = ui.item.backboneView().model
      
      # Remove it model from search results collection
      model.collection.remove model
      
      # Associate playlist ID with the track
      model.set "playlist_id", @model.get("id")
      
      # Add new track to the collection
      @model.tracks.add model
      
