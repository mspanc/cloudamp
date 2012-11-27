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
          connectWith : ".playlist-dragndrop"
          items       : ">*:not(.playlist-dragndrop-invalid)"
          appendTo    : "#app"
          helper      : "clone"
          start       : (event, ui) ->
            # Draw placeholder
            $(".ui-sortable-placeholder")
              .css("visibility", "visible")
              .append($('<td colspan="5" class="playlist-dragndrop-placeholder"></td>'))


            # Add temporary filler to allow dropping below end of tbody
            $("#panel_playlists .playlist-container.active table")
              .css("height", "100%")

            filler = $('<tr class="playlist-dragndrop-filler playlist-dragndrop-invalid"><td colspan="5"> </td></tr>')
            $("#panel_playlists .playlist-container.active tbody")
              .css("height", "100%")
              .append(filler)
              
            $(".playlist-dragndrop-filler").height($(".playlist-dragndrop-filler").closest(".playlist-container").height())

          stop       : (event, ui) ->
            # Remove temporary filler to allow dropping below end of tbody
            $("#panel_playlists .playlist-container.active table")
              .css("height", "")

            $("#panel_playlists .playlist-container.active tbody")
              .css("height", "")

            $("#panel_playlists .playlist-container.active .playlist-dragndrop-filler")
              .remove()

