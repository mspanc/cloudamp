$ ->
  class CloudAmp.Views.App extends Backbone.View
    el : $ "#app"
      
    initialize: ->
      @search_panel_view    = new CloudAmp.Views.SearchPanel
      @playlists_panel_view = new CloudAmp.Views.PlaylistsPanel
      @player_widget        = null
      @player_playing       = false
      
    
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
      @player_playing = false

      if $("iframe").length == 0
        SC.oEmbed track_url, @player_widget_options(), (oEmbed) =>
          $("#panel_player .embed").html oEmbed.html
          @player_widget = SC.Widget($("iframe")[0])
          
          @player_widget.bind SC.Widget.Events.READY, @on_player_ready

      else
        # TODO add pending tracks
        @player_widget.load track_url, @player_widget_options()
    
    
    pause_track: ->
      @player_widget.pause()
      
    resume_track: ->
      @player_widget.play()
      

    on_player_ready: =>
      console.log "READY"
      @player_widget.bind SC.Widget.Events.PLAY,          @on_player_play
      @player_widget.bind SC.Widget.Events.PAUSE,         @on_player_pause
      @player_widget.bind SC.Widget.Events.FINISH,        @on_player_finish
      @player_widget.bind SC.Widget.Events.PLAY_PROGRESS, @on_player_play_progress

    on_player_play_progress: (param) =>
      if @player_playing == false and param.loadedProgress == 1
        @player_playing = true
        @mark_playing_track()

      
    on_player_play: =>
      console.log "PLAYING"
      @mark_playing_track()


    on_player_pause: =>
      @mark_paused_track()


    on_player_finish: =>
      console.log "FINISH"


    mark_playing_track: ->
      @player_widget.getCurrentSound (current_track) =>
        paused_track = $(".track.paused:first")
        console.log paused_track
        if paused_track.length != 0
          track_view = paused_track.backboneView()
        else
          loading_track = $(".track.loading:first")
          if loading_track.length != 0
            track_view = loading_track.backboneView()
          else
            throw new CloudAmp.Errors.UnexpectedTrackStateChange(current_track.uri, "(no loading or paused track found)")
          
            
        if track_view.model.get("track_url") != current_track.uri
          throw new CloudAmp.Errors.UnexpectedTrackStateChange(current_track.uri, track_view.model.get("track_url"))
          
        track_view.mark_as_playing()
    
    
    mark_paused_track: ->
      @player_widget.getCurrentSound (current_track) =>
        paused_track_view = $(".track.playing").backboneView()
        
        if paused_track_view.model.get("track_url") != current_track.uri
          throw new CloudAmp.Errors.UnexpectedTrackStateChange(current_track.uri, paused_track_view.model.get("track_url"))
          
        paused_track_view.mark_as_paused()
        
