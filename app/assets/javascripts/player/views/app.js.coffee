# This file is part of CloudAmp. For more information about CloudAmp,
# please visit http://github.com/saepia/cloudamp. 
#
# Licensed under GNU Affero General Public License available 
# at http://www.gnu.org/licenses/agpl-3.0.html
#
# (c) 2012 Marcin Lewandowski

$ ->
  # Main application view.
  #
  # It is responsible for several things:
  #  * initializing and keeping references to panel views,
  #  * initializing and handling SoundCloud player widget,
  #  * handling top menu events,
  #  * bootstrapping initial playlists' data
  #
  # Player logic can be described in the following way:
  #
  #  * If widget wasn't embedded yet, try to do that when user clicks plays track.
  #  * If it is already embedded, try to reload the track, but if user invoked
  #    playback several times in a row, and widget is still loading, remember
  #    last track clicked by user and wait for widget to reload in order to
  #    avoid crashes.
  #  * Listen for widget's play/pause events and update UI respectively.
  #  * Listen for widget's play progress event to determine when really playback
  #    starts and update UI respectively.
  #
  class CloudAmp.Views.App extends Backbone.View
    el : $ "#app"
      
    # Initialize child panels and widget variables
    initialize: ->
      @search_panel_view    = new CloudAmp.Views.SearchPanel
      @playlists_panel_view = new CloudAmp.Views.PlaylistsPanel
      @player_widget        = null
      @player_initialized   = false
      @pending_track_url    = null
    
    # Top menu events
    events:
      "click #nav_about"       : "show_modal_about"
      "click #nav_bookmarklet" : "show_modal_bookmarklet"
    
    
    # Bootstraps playlists.
    #
    # It passes the data to PlaylistPanel view, please see its documentation
    # for more information.
    #
    # @param playlists initial playlists' data
    bootstrap_playlists: (playlists) ->
      @playlists_panel_view.bootstrap(playlists)
      
    
    # Shows "About" modal window
    show_modal_about: ->
      @$("#modal_about").modal "show"


    # Shows "Bookmarklet" modal window
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


    # Plays track specified as its URL. Passed URL has to be URI in SoundCloud 
    # docs terminology, not permalink.
    #
    # It handles embedding and reloading of the widget.
    #
    # @param track URL to play
    play_track: (track_url) ->
      @show_player_widget()
      
      # Embed the widget if that hasn't happened yet
      if $("iframe").length == 0
        SC.oEmbed track_url, @player_widget_options(), (oEmbed) =>
          $("#panel_player .embed").html oEmbed.html
          @player_widget = SC.Widget($("iframe")[0])
          
          @player_widget.bind SC.Widget.Events.READY, @on_player_ready

      else
        # Reload the widget
        reload_options = @player_widget_options()
        
        # Ensure that widget is loaded, otherwise store track URL for
        # use when it finally gets loaded.
        if @player_initialized == true
          @player_initialized = false
          reload_options.callback = @on_player_reload
          
          @player_widget.load track_url, reload_options
        else
          @pending_track_url = track_url
    
    
    # Hides player widget and stops playback. Used in cases when playback
    # has to be stopped, like when user removes last track on the playlist.
    hide_player_widget: =>
      @$("#panel_player iframe").hide()
      @pause_track()


    # Shows player widget.
    show_player_widget: =>
      @$("#panel_player iframe").show()
    

    # Pauses the playback.
    pause_track: ->
      @player_widget.pause()
      

    # Resumes previously paused playback.
    resume_track: ->
      @player_widget.play()


    # Unbinds from playback progress events. We don't need to listen to them after 
    # we found that playback has started.
    unbind_from_playback_progress: ->
      @player_widget.unbind SC.Widget.Events.PLAY_PROGRESS, @on_player_play_progress


    # Binds to playback progress events. We need them only to find when playback 
    # starts.
    bind_to_playback_progress: ->
      @player_widget.bind SC.Widget.Events.PLAY_PROGRESS, @on_player_play_progress
      

    # Callback that is called when the widget reloads. It checks if there was
    # any pending track (set to playing when widget was still reloading) and
    # plays it if necessary.
    on_player_reload: =>
      @bind_to_playback_progress()
      @player_initialized = true
      
      if @pending_track_url != null
        track_url = @pending_track_url
        @pending_track_url = null
        @play_track track_url
      
      
      
    # Callback that is called when the widget is loaded for the first time.
    # It initializes necessary event bindings.
    on_player_ready: =>
      @player_widget.bind SC.Widget.Events.PLAY,          @on_player_play
      @player_widget.bind SC.Widget.Events.PAUSE,         @on_player_pause
      @player_widget.bind SC.Widget.Events.FINISH,        @on_player_finish
      @bind_to_playback_progress()
      @player_initialized = true


    # Callback that is called when the widget reports any playback progress.
    # After we determine that track is really playing we can stop tracking
    # this event.
    #
    # @param event's parameters hash
    on_player_play_progress: (param) =>
      if (param.loadedProgress != null and param.loadedProgress != 0)
        @unbind_from_playback_progress()
        @mark_playing_track()

      
    # Callback that is called when the widget reports that user clicked play
    # button.
    #
    # Updates the UI respectively.
    on_player_play: =>
      @mark_playing_track()


    # Callback that is called when the widget reports that user clicked pause
    # button.
    #
    # Updates the UI respectively.
    on_player_pause: =>
      @mark_paused_track()


    # Callback that is called when the widget reports that track has finished.
    #
    # Attempts to play next track.
    on_player_finish: =>
      @player_widget.getCurrentSound (current_track) =>
        track_view = $(".track[track_url='" + current_track.uri + "']:first").backboneView()
        track_view.play_next()
          

    # Finds track that should be marked as playing and updates the UI.
    #
    # Helper used by other functions of this view that update the UI.
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
    
    
    # Finds track that should be marked as paused and updates the UI.
    #
    # Helper used by other functions of this view that update the UI.
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
          
