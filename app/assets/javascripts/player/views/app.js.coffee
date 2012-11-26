$ ->
  class CloudAmp.Views.App extends Backbone.View
    el : $ "#app"
      
    initialize: ->
      @search_panel_view    = new CloudAmp.Views.SearchPanel
      @playlists_panel_view = new CloudAmp.Views.PlaylistsPanel
      @player_widget        = null
      @player_initialized   = false
      @pending_track_url    = null
      
    events:
      "click #nav_about"       : "show_modal_about"
      "click #nav_bookmarklet" : "show_modal_bookmarklet"
    
    bootstrap_playlists: (playlists) ->
      @playlists_panel_view.bootstrap(playlists)
      
      
    show_modal_about: ->
      @$("#modal_about").modal "show"

    show_modal_bookmarklet: ->
      @$("#modal_bookmarklet").modal "show"

    # Generates object with options passed to SoundCloud Player Widget.
    #
    # Seems that if we create static options object it's "url" property gets 
    # overriden by SoundCloud Widget API, so let's regenerate them on each call.
    #
    # @return object with options for player
    player_widget_options: ->
      auto_play : true
      auto_advance : false


    play_track: (track_url) ->
      @show_player_widget()
      if $("iframe").length == 0
        SC.oEmbed track_url, @player_widget_options(), (oEmbed) =>
          $("#panel_player .embed").html oEmbed.html
          @player_widget = SC.Widget($("iframe")[0])
          
          @player_widget.bind SC.Widget.Events.READY, @on_player_ready

      else
        reload_options = @player_widget_options()
        
        if @player_initialized == true
          @player_initialized = false
          reload_options.callback = @on_player_reload
          
          @player_widget.load track_url, reload_options
        else
          @pending_track_url = track_url
    
    
    hide_player_widget: =>
      @$("#panel_player iframe").hide()
      @pause_track()

    show_player_widget: =>
      @$("#panel_player iframe").show()
    
    pause_track: ->
      @player_widget.pause()
      

    resume_track: ->
      @player_widget.play()


    unbind_from_playback_progress: ->
      @player_widget.unbind SC.Widget.Events.PLAY_PROGRESS, @on_player_play_progress


    bind_to_playback_progress: ->
      @player_widget.bind SC.Widget.Events.PLAY_PROGRESS, @on_player_play_progress
      

    on_player_reload: =>
      @bind_to_playback_progress()
      @player_initialized = true
      
      if @pending_track_url != null
        track_url = @pending_track_url
        @pending_track_url = null
        @play_track track_url
      
      
      
    on_player_ready: =>
      @player_widget.bind SC.Widget.Events.PLAY,          @on_player_play
      @player_widget.bind SC.Widget.Events.PAUSE,         @on_player_pause
      @player_widget.bind SC.Widget.Events.FINISH,        @on_player_finish
      @bind_to_playback_progress()
      @player_initialized = true

    on_player_play_progress: (param) =>
      if (param.loadedProgress != null and param.loadedProgress != 0)
        @unbind_from_playback_progress()
        @mark_playing_track()

      
    on_player_play: =>
      @mark_playing_track()


    on_player_pause: =>
      @mark_paused_track()


    on_player_finish: =>
      @player_widget.getCurrentSound (current_track) =>
        track_view = $(".track[track_url='" + current_track.uri + "']:first").backboneView()
        track_view.play_next()
          

    mark_playing_track: ->
      @player_widget.getCurrentSound (current_track) =>
        track_view = $(".track.loading[track_url='" + current_track.uri + "'], .track.paused[track_url='" + current_track.uri + "']").first().backboneView()
          
        # There is a chance that we got this callback for song that was
        # loading while user removed playlist that contained it.
        #
        # If it is not the case, mark it as playing
        if track_view == null
          @hide_player_widget()
        else
          track_view.mark_as_playing() 
    
    
    mark_paused_track: ->
      @player_widget.getCurrentSound (current_track) =>
        # Find view associated with currently playing track
        paused_track_view = $(".track.playing").backboneView()
        
        # There's a chance that this view does not exist if we are removing
        # paused track and it is last track in the playlist
        if paused_track_view != null
        
          # Ensure we are doing things on right track
          if paused_track_view.model.get("track_url") != current_track.uri
            throw new CloudAmp.Errors.UnexpectedTrackStateChange(current_track.uri, paused_track_view.model.get("track_url"))
            
          paused_track_view.mark_as_paused()
          
