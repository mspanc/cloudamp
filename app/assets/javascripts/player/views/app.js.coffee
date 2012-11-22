$ ->
  class CloudAmp.Views.App extends Backbone.View
    el: $ "#app"
    
    events:
      'click #search' : 'search'
      
    initialize: ->
      console.log("App init")
    
    search: () =>
      console.log("Search")
      
  instance = new CloudAmp.Views.App
