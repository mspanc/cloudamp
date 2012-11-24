$ ->
  class CloudAmp.Views.PlaylistContainer extends Backbone.View
    template   : _.template($('#playlist-container-template').html()),
    tagName    : "div"
    className  : "tab-pane playlist-container"
    id         : =>
      "playlist" + @model.get("id")
    attributes : =>
      "playlist_id" : @model.get("id")
      
    
    initialize: ->
      @model.on         "destroy", @remove
      @model.tracks.on  "add",     @update_empty_message
      @model.tracks.on  "remove",  @update_empty_message
      
    teardown: ->
      @model.off        "destroy", @remove
      @model.tracks.off "add",     @update_empty_message
      @model.tracks.off "remove",  @update_empty_message
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      return @
    
    
    update_empty_message: =>
      if @model.tracks.size() == 0  
        @$(".message-empty").show()
      else
        @$(".message-empty").hide()
      
    
    on_track_added: =>
      console.log "AAA"
      
