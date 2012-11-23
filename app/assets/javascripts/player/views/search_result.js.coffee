$ ->
  class CloudAmp.Views.SearchResult extends Backbone.View
    tagName  : "li"
    template : _.template($('#search-result-template').html()),
    
    initialize: ->
      @model.on "destroy", @remove
      
    teardown: ->
      @model.off "destroy", @remove
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      
      return @
      
