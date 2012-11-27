# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # View responsible for rendering single track, regardless if it is located
  # in the playlist track list or search results.
  #
  # It keeps track's playback state (it is in view, not in model, because
  # it is somehow also presentation layer, even it is not visual).
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

      
    # Cleanups the track. Attempts to play next track if currently removed track
    # is not the only one.
    clear: ->
      if @state != Track.State.STOPPED
        if @model.collection.size() > 1
          @play_next()
        else
          window.APP.hide_player_widget()
        
      @model.clear()
    

    # Renders track row.
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
      

    # Helper function that checks if action buttons are disabled or not.
    #
    # @return true if action buttons are disabled, false otherwise
    action_buttons_are_disabled: ->
      @$("td.action a:first").attr("disabled") == "disabled"


    # Helper function that disables tracks' action buttons 
    disable_action_buttons: ->
      @$("td.action a")
        .attr("disabled", true)
        .css("cursor", "progress")


    # Helper function that enables tracks' action buttons 
    enable_action_buttons: ->
      @$("td.action a")
        .attr("disabled", false)
        .css("cursor", "")
        

    # Helper function that sets proper track row appeareance.
    #
    # Valid row classes are "playing", "loading", "paused" and null (for "stopped").
    # They are mapped directly to CSS classes.
    #
    # @param new_class "playing", "loading", "paused" or null (for "stopped" state)
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
      


    # Helper function that sets track's play/pause button tooltip.
    #
    # @param new_text tooltip's text
    set_play_action_tooltip: (new_text) ->
      @$("td.action-play a").attr("data-original-title", new_text)
    
    
    
    # Handles attempts to play or pause this track.
    #
    # Invoked by play/pause action button.
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

          # Save state
          @set_state Track.State.LOADING

          # Start playback
          window.APP.play_track(@model.get("track_url"))
          
          

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


    # Tries to play next track.
    play_next: ->
      @mark_as_stopped()

      if @$el.next().length == 0
          @$el.parent().find(".track:first").backboneView().invoke_playback_or_pause()
          @$el.closest(".playlist-container").scrollTop(0)
          
      else
        @$el.next().backboneView().invoke_playback_or_pause()
    


    # Helper function that sets current track state. Extracted mostly for debugging.
    set_state: (new_state) =>
      @state = new_state


      
    # Marks this track as playing
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
      @set_state Track.State.PLAYING
      


    
    # Marks this track as paused
    mark_as_paused: ->
      throw new CloudAmp.Errors.InvalidTrackStateTransition(@model.get("track_url"), @state, Track.State.PAUSED) if @state != Track.State.PLAYING

      # Set proper appeareance
      @set_row_appearance("paused")
      @set_play_action_icon("play")
      @set_play_action_tooltip("Resume playback of this track")

      @enable_action_buttons()

      @set_state Track.State.PAUSED
      
      
    # Marks this track as stopped
    mark_as_stopped: ->
      throw new CloudAmp.Errors.InvalidTrackStateTransition(@model.get("track_url"), @state, Track.State.STOPPED) if @state == Track.State.STOPPED
      
      # Set proper appeareance
      @set_row_appearance(null)
      @set_play_action_icon("play")
      @set_play_action_tooltip("Play this track")

      @enable_action_buttons()

      @set_state Track.State.STOPPED
      
    

