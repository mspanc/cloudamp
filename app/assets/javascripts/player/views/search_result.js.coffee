$ ->
  class CloudAmp.Views.SearchResult extends Backbone.View
    template   : _.template($('#search-result-template').html()),
    tagName    : "li"
    attributes : =>
      track_url : @model.get("track_url")
    
    initialize: ->
      @model.on "destroy", @remove
      
    teardown: ->
      @model.off "destroy", @remove
      
    
    render: ->
      @$el.html(@template(@model.toJSON()))
      
      return @
      
