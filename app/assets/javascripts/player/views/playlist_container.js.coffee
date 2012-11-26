$ ->
  class CloudAmp.Views.PlaylistContainer extends Backbone.View
    template   : _.template($('#playlist-container-template').html()),
    tagName    : "div"
    className  : "tab-pane playlist-container"
    
    # User by tab hooks
    id         : =>
      "playlist" + @model.get("id")

    # User by drag'n'drop lookup
    attributes : =>
      "playlist_id" : @model.get("id")
      
    
    initialize: ->
      @model.on         "destroy", @remove, @
      @model.tracks.on  "reset",   @render_all_tracks
      @model.tracks.on  "reset",   @update_empty_message
      @model.tracks.on  "add",     @update_empty_message
      @model.tracks.on  "add",     @calculate_position
      @model.tracks.on  "add",     @store
      @model.tracks.on  "remove",  @update_empty_message
      @model.tracks.on  "remove",  @calculate_position
      
    teardown: ->
      @model.off        "destroy", @remove, @
      @model.tracks.off "reset",   @render_all_tracks
      @model.tracks.off "reset",   @update_empty_message
      @model.tracks.off "add",     @update_empty_message
      @model.tracks.off "add",     @calculate_position
      @model.tracks.off "add",     @store
      @model.tracks.off "remove",  @update_empty_message
      @model.tracks.off "remove",  @calculate_position
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      return @
    

    render_one_track: (track) =>
      view   = new CloudAmp.Views.Track({ model: track });
      output = view.render().el
      @$("tbody").append(output);

      

    render_all_tracks: (tracks) =>
      tracks.each (track) =>
        @render_one_track track

    
    update_empty_message: =>
      if @model.tracks.size() == 0  
        @$(".message-empty").show()
      else
        @$(".message-empty").hide()
      
    
    calculate_position: =>
      @$(".track").each (i, element) -> 
        $(element).backboneView().model.set("position", i)
        
        
    store: =>
      @$(".track").each (i, element) -> 
        $(element).backboneView().model.save
          success: =>
            console.log "SUCCESS" # TODO
          error: =>
            console.log "ErROR"
      
