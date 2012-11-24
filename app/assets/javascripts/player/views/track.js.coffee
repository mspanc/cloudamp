$ ->
  class CloudAmp.Views.Track extends Backbone.View
    template   : _.template($('#track-template').html()),
    tagName    : "tr"
    className  : "track"
    
    initialize: ->
      @model.on "destroy", @remove
      
    teardown: ->
      @model.off "destroy", @remove
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      
      return @
      
