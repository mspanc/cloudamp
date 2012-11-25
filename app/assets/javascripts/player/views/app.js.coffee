$ ->
  class CloudAmp.Views.App extends Backbone.View
    el : $ "#app"
      
    initialize: ->
      @search_panel_view    = new CloudAmp.Views.SearchPanel
      @playlists_panel_view = new CloudAmp.Views.PlaylistsPanel
      @player_widget        = null
      
    
    bootstrap_playlists: (playlists) ->
      @playlists_panel_view.bootstrap(playlists)
      

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
      if $("iframe").length == 0
        SC.oEmbed track_url, @player_widget_options(), (oEmbed) =>
          $("#panel_player .embed").html oEmbed.html
          @player_widget = SC.Widget($("iframe")[0])
          
          @player_widget.bind SC.Widget.Events.READY, @on_player_ready

      else
        # TODO add pending tracks
        reload_options = @player_widget_options()
        reload_options.callback = @on_player_reload
          
        @player_widget.load track_url, reload_options
    
    
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
      
      
      
    on_player_ready: =>
      @player_widget.bind SC.Widget.Events.PLAY,          @on_player_play
      @player_widget.bind SC.Widget.Events.PAUSE,         @on_player_pause
      @player_widget.bind SC.Widget.Events.FINISH,        @on_player_finish
      @bind_to_playback_progress()

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
        track_view = $(".track[track_url='" + current_track.uri + "']:first").backboneView()
          
        track_view.mark_as_playing()
    
    
    mark_paused_track: ->
      @player_widget.getCurrentSound (current_track) =>
        paused_track_view = $(".track.playing").backboneView()
        
        if paused_track_view.model.get("track_url") != current_track.uri
          throw new CloudAmp.Errors.UnexpectedTrackStateChange(current_track.uri, paused_track_view.model.get("track_url"))
          
        paused_track_view.mark_as_paused()
        
