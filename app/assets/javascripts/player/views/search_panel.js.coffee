$ ->
  class CloudAmp.Views.SearchPanel extends Backbone.View
    el: $ "#panel_search"
    
    events:
      'click #search_button' : 'perform_search'
      
    initialize: ->
      @search_result_collection = new CloudAmp.Models.SearchResultCollection
      @search_result_collection.on 'reset', @render_search_results
      


    perform_search: () ->
      @search_result_collection.fetch { query : @$("#search_field").val() }
      

      
    render_search_results: (results) ->
      results.each (result) ->
        view = new CloudAmp.Views.Track({ model: result });
        @$("#panel_search_results tbody").append(view.render().el);
    
        $("#panel_search_results tbody")
          .disableSelection()
          .sortable
            connectWith : ".playlist-dragndrop"
          
