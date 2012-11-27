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
          items       : ">*:not(.message-empty)"
          appendTo    : "#app"
          helper      : "clone"
          start       : (event, ui) ->
            $(".ui-sortable-placeholder")
              .css("visibility", "visible")
              .append($('<td colspan="5" class="playlist-dragndrop-placeholder"></td>'))

