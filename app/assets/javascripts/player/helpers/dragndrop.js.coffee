# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Helper functions for playlists drag'n'drop functionality
  class CloudAmp.Helpers.DragNDrop 
    # Initializes passed element as a playlist container that will allow its
    # children to be drag'n'dropped.
    #
    # It should be applied to <tbody> elements of search results and each
    # playlist.
    #
    # @param container <tbody> element of search results or playlist container
    @initialize_dragndrop_playlist_container: (container) ->
      container
        .disableSelection()
        .sortable
          connectWith : ".playlist-dragndrop, .playlist-container.active"
          items       : ">*:not(.playlist-dragndrop-invalid)"
          appendTo    : "#app"
          helper      : "clone"
          start       : (event, ui) ->
            # Draw placeholder
            $(".ui-sortable-placeholder")
              .css("visibility", "visible")
              .append($('<td colspan="5" class="playlist-dragndrop-placeholder"></td>'))

          stop       : (event, ui) ->
            # If element was dropped on empty space below tbody, move it to tbody
            # and force call drop event handler
            if ui.item.parent().hasClass("playlist-container")
              tbody = ui.item.parent().find("tbody")
              tbody.append(ui.item)
              
              tbody.backboneView().on_track_dropped event, ui
              

