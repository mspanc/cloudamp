$ ->
  class CloudAmp.Views.Track extends Backbone.View
    template   : _.template($('#track-template').html()),
    tagName    : "tr"
    className  : "track"
    
    initialize: ->
      @model.on "destroy", @remove, @
      
    teardown: ->
      @model.off "destroy", @remove, @
      

    events:
      "click .action-remove a": "clear"

    
    clear: ->
      @model.clear()
    

    render: ->
      @$el.html(@template(@model.toJSON()))
      @$("*[rel=tooltip]").tooltip()      
      return @
      
      

