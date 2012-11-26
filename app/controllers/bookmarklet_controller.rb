class BookmarkletController < ApplicationController
  before_filter :authenticate_user_with_forced_forbidden
  
  def add
    sc_track = soundcloud.get('/resolve', :url => params[:uri])
    
    Playlist.transaction do
      Track.transaction do
        db_track = Track.new
        db_track.title = sc_track.title
        db_track.artwork_url = sc_track.artwork_url
        db_track.track_url = sc_track.uri

        seconds = sc_track.duration / 1000
        minutes = seconds / 60
        seconds = seconds % 60
        hours   = minutes / 60
        minutes = minutes % 60

        db_track.duration = sprintf("%02d:%02d:%02d", hours.to_i, minutes.to_i, seconds.to_i)
        
        db_track.playlist = current_user.playlists.ordered.first
        
        db_track.save!
        
        send_file File.join(Rails.root, "app", "assets", "images", "empty.gif"), :content_type => "image/gif"
      end
    end
    
    rescue Soundcloud::ResponseError => e
      logger.warn "[bookmarklet] Unable to resolve #{params[:uri]}: #{e} #{e.message}"
      render :text => "", :status => 404

    rescue 
      logger.warn "[bookmarklet] Unable to store track #{params[:uri]}: #{$!.class} #{$!}"
      render :text => "", :status => 500
  end
end
