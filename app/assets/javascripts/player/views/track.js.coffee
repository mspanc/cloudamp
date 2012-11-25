$ ->
  class CloudAmp.Views.Track extends Backbone.View
    @State     :
      STOPPED  : 0
      LOADING  : 1
      PLAYING  : 2
      PAUSED   : 3
      
    template   : _.template($('#track-template').html()),
    tagName    : "tr"
    className  : "track"
    state      : Track.State.STOPPED
    attributes : ->
      track_url : @model.get("track_url")
    
    initialize: ->
      @model.on "destroy", @remove, @
      
    teardown: ->
      @model.off "destroy", @remove, @
      

    events:
      "click .action-remove a" : "clear"
      "click .action-play a"   : "invoke_playback_or_pause"

    
    clear: ->
      @play_next() if @state == Track.State.PLAYING 
        
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
      

    action_buttons_are_disabled: ->
      @$("td.action a:first").attr("disabled") == "disabled"

    disable_action_buttons: ->
      @$("td.action a")
        .attr("disabled", true)
        .css("cursor", "progress")

    enable_action_buttons: ->
      @$("td.action a")
        .attr("disabled", false)
        .css("cursor", "")
        

    set_row_appearance: (new_class = null) ->
      @$el
        .removeClass("playing")
        .removeClass("loading")
        .removeClass("paused")
        
      if new_class != null
        @$el
          .addClass(new_class)

    set_play_action_icon: (new_icon) ->
      @$("td.action-play i")
        .removeClass("icon-spinner")
        .removeClass("icon-pause")
        .removeClass("icon-play")
        .addClass("icon-" + new_icon)
      

    set_play_action_tooltip: (new_text) ->
      @$("td.action-play a").attr("data-original-title", new_text)
    
    
    
    

    invoke_playback_or_pause: ->
      return if @action_buttons_are_disabled()
      
      switch @state
        when Track.State.STOPPED
          # Disable action buttons to prevent multiple clicking
          @disable_action_buttons()

          # Find existing loading tracks and stop them
          $(".track.loading").each (i, track) -> 
            $(track).backboneView().mark_as_stopped()


          # Set appeareance - background should indicate that we are loading
          # and action buttons should indicate the same
          @set_row_appearance("loading")
          @set_play_action_icon("spinner")
          @set_play_action_tooltip("This track is loading...")


          # Start playback
          window.APP.play_track(@model.get("track_url"))
          
          # Save state
          @state = Track.State.LOADING
          

        when Track.State.PAUSED
          # Disable action buttons to prevent multiple clicking
          @disable_action_buttons()
          
          
          # Pause playback
          window.APP.resume_track()


        when Track.State.PLAYING
          # Disable action buttons to prevent multiple clicking
          @disable_action_buttons()
          
          # Pause playback
          window.APP.pause_track()


    play_next: ->
      @mark_as_stopped()

      if @$el.next().length == 0
        if @$el.parent().find(".track").length != 0
          @$el.parent().find(".track:first").backboneView().invoke_playback_or_pause()
          @$el.closest(".playlist-container").scrollTop(0)
          
      else
        @$el.next().backboneView().invoke_playback_or_pause()
    

      
    mark_as_playing: ->
      throw new CloudAmp.Errors.InvalidTrackStateTransition(@model.get("track_url"), @state, Track.State.PLAYING) if @state != Track.State.LOADING and @state != Track.State.PAUSED

      # Find existing playing and paused tracks and stop them
      $(".track.playing, .track.paused").each (i, track) -> 
        $(track).backboneView().mark_as_stopped()

      
      # Set proper appeareance
      @set_row_appearance("playing")
      @set_play_action_icon("pause")
      @set_play_action_tooltip("Pause this track")
        
      @enable_action_buttons()
      @state = Track.State.PLAYING
      
      
    mark_as_paused: ->
      throw new CloudAmp.Errors.InvalidTrackStateTransition(@model.get("track_url"), @state, Track.State.PAUSED) if @state != Track.State.PLAYING

      # Set proper appeareance
      @set_row_appearance("paused")
      @set_play_action_icon("play")
      @set_play_action_tooltip("Resume playback of this track")

      @enable_action_buttons()

      @state = Track.State.PAUSED
      
      
    mark_as_stopped: ->
      throw new CloudAmp.Errors.InvalidTrackStateTransition(@model.get("track_url"), @state, Track.State.STOPPED) if @state == Track.State.STOPPED
      
      # Set proper appeareance
      @set_row_appearance(null)
      @set_play_action_icon("play")
      @set_play_action_tooltip("Play this track")

      @enable_action_buttons()

      @state = Track.State.STOPPED
      
    

