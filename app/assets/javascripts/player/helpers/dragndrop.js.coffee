$ ->
  class CloudAmp.Helpers.DragNDrop 
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

