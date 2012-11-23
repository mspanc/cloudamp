$ ->
  class CloudAmp.Views.App extends Backbone.View
    el: $ "#app"
    
    initialize: ->
      console.log("CloudAmp.Views.App init")
      @search_view = new CloudAmp.Views.SearchPanel
    

