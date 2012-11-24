$ ->
  class CloudAmp.Views.PlaylistContainer extends Backbone.View
    template  : _.template($('#playlist-container-template').html()),
    tagName   : "div"
    className : "tab-pane"
    id        : =>
      "playlist" + @model.get("id")
      
    
    initialize: ->
      @model.on "destroy", @remove
      
    teardown: ->
      @model.off "destroy", @remove
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      return @
      
