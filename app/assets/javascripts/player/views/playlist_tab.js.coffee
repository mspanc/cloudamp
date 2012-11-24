$ ->
  class CloudAmp.Views.PlaylistTab extends Backbone.View
    template : _.template($('#playlist-tab-template').html()),
    tagName  : "li"
    
    initialize: ->
      @model.on "destroy", @remove
      
    teardown: ->
      @model.off "destroy", @remove
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      
      return @
      
