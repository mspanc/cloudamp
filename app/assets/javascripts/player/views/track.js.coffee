$ ->
  class CloudAmp.Views.Track extends Backbone.View
    template   : _.template($('#track-template').html()),
    tagName    : "tr"
    className  : "track"
    
    initialize: ->
      @model.on "destroy", @remove, @
      
    teardown: ->
      @model.off "destroy", @remove, @
      

    events:
      "click .action-remove a" : "clear"
      "click .action-play a"   : "play"

    
    clear: ->
      @model.clear()
    

    render: ->
      # Render the template
      @$el.html(@template(@model.toJSON()))
      
      # Enable tooltips on track buttons
      @$("*[rel=tooltip]").tooltip()  
      
      # Play button should be green when hovered, remove should be red.
      # Apply that using JS instead of CSS's :hover to utilize Bootstrap
      # default classes and do not reinvent the wheel.
      @$("td.action-play a")
        .mouseover ->
          $(@).addClass("btn-success")
        .mouseout ->
          $(@).removeClass("btn-success")

      @$("td.action-remove a")
        .mouseover ->
          $(@).addClass("btn-danger")
        .mouseout ->
          $(@).removeClass("btn-danger")
        
      return @
      
      
    play: ->
      @$("td.action a")
        .attr("disabled", true)
        
      @$("td.action-play i")
        .removeClass("icon-play")
        .addClass("icon-spinner")
      
      SC.oEmbed @model.get("track_url"), { auto_play : true }, (oEmbed) ->
        $("#panel_player .embed").html oEmbed.html
      
