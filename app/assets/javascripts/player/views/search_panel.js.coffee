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
        view = new CloudAmp.Views.SearchResult({ model: result });
        @$("#panel_search_results ul").append(view.render().el);
    
        $("#panel_playlists_contents ul, #panel_search_results ul")
          .disableSelection()
          .sortable
            connectWith : ".playlist-dragndrop"
          
