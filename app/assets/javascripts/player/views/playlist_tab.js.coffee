$ ->
  class CloudAmp.Views.PlaylistTab extends Backbone.View
    tagName: "li"
    template : _.template($('#playlist-tab-template').html()),
    
    initialize: ->
      @model.on "destroy", @remove
      
    teardown: ->
      @model.off "destroy", @remove
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      
      return @
      
