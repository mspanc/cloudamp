# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # This file is part of CloudAmp. For more information about CloudAmp,
  # please visit http://github.com/saepia/cloudamp. 
  #
  # Licensed under GNU Affero General Public License available 
  # at http://www.gnu.org/licenses/agpl-3.0.html
  #
  # (c) 2012 Marcin Lewandowski
  # 
  # View responsible for handling search panel.
  #
  # It handles all UI interactions, search results rendering etc.
  class CloudAmp.Views.SearchPanel extends Backbone.View
    el: $ "#panel_search"
    
    events:
      "click    #search_button" : "perform_search"
      "keypress #search_field"  : "handle_enter_in_search_field"
        
    initialize: ->
      @search_result_collection = new CloudAmp.Models.SearchResultCollection
      @search_result_collection.on 'reset', @render_search_results
      CloudAmp.Helpers.DragNDrop.initialize_dragndrop_playlist_container @$("tbody")


    # Invokes search when users presses ENTER in the search field
    #
    # @param event event associated with the key press
    handle_enter_in_search_field: (event) ->
      @perform_search() if event.keyCode == 13
       

    # Invokes search.
    #
    # Displays spinner, cleanups previous search results.
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

      
    # Renders search results
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

