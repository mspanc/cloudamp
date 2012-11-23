$ ->
  class CloudAmp.Views.SearchPanel extends Backbone.View
    el: $ ".panel-search"
    
    events:
      'click #search_button' : 'perform_search'
      
    initialize: ->
      console.log("CloudAmp.Views.SearchPanel init")
      
      @search_result_collection = new CloudAmp.Models.SearchResultCollection
      @search_result_collection.on 'reset', @render_search_results
      


    perform_search: () ->
      @search_result_collection.fetch { query : @$("#search_field").val() }
      

      
    render_search_results: (results) ->
      console.log("CloudAmp.Views.SearchPanel#render_search_results")
      
      results.each (result) ->
        view = new CloudAmp.Views.SearchResult({ model: result });
        @$(".search-results ul").append(view.render().el);
    

