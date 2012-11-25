$ ->
  class CloudAmp.Views.SearchPanel extends Backbone.View
    el: $ "#panel_search"
    
    events:
      "click    #search_button" : "perform_search"
      "keypress #search_field"  : "handle_enter_in_search_field"
        
    initialize: ->
      @search_result_collection = new CloudAmp.Models.SearchResultCollection
      @search_result_collection.on 'reset', @render_search_results
      @$("tbody")
        .disableSelection()
        .sortable
          appendTo    : "#app"
          helper      : "clone"
          connectWith : ".playlist-dragndrop"


    handle_enter_in_search_field: (event) ->
      @perform_search() if event.keyCode == 13
       

    perform_search:  ->
      # Lock search button, display spinner and busy mouse cursor
      @$(".search-box a").attr("disabled", true)
      @$(".search-box a").css("cursor", "progress")
      @$(".search-box a i")
        .removeClass("icon-search")
        .addClass("icon-spinner")
        
      # Cleanup existing search results
      @$("#panel_search_results .track").each (i, track) ->
        $(track).backboneView().model.destroy()
        return true

      # Fetch new search results
      @search_result_collection.fetch { query : @$("#search_field").val() }

      
    render_search_results: (results) =>
      # Unlock search button and restore original icon & mouse cursor
      @$(".search-box a").attr("disabled", false)
      @$(".search-box a").css("cursor", "")
      @$(".search-box a i")
        .addClass("icon-search")
        .removeClass("icon-spinner")

      results.each (result) ->
        view = new CloudAmp.Views.Track({ model: result });
        @$("#panel_search_results tbody").append(view.render().el);

