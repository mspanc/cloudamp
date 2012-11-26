class PlaylistsController < ApplicationController
  before_filter :authenticate_user
  
  # POST /playlists
  # POST /playlists.json
  def create
    Playlist.transaction do
      @playlist = Playlist.new(params[:playlist])
      @playlist.user = current_user

      respond_to do |format|
        if @playlist.save
          format.json { render json: @playlist, status: :created, location: @playlist }
        else
          format.json { render json: @playlist.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /playlists/1
  # PUT /playlists/1.json
  def update
    Playlist.transaction do
      @playlist = Playlist.find(params[:id])

      if @playlist.user != current_user
        logger.warn "[playlists] Attempt to update Playlist ##{params[:id]} without permission"
        respond_to do |format|
          format.json { head :forbidden }
        end
      else
        respond_to do |format|
          if @playlist.update_attributes(params[:playlist])
            format.json { head :no_content }
          else
            format.json { render json: @playlist.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.json
  def destroy
    Playlist.transaction do
      @playlist = Playlist.find(params[:id])

      if @playlist.user != current_user
        logger.warn "[playlists] Attempt to delete Playlist ##{params[:id]} without permission"
        respond_to do |format|
          format.json { head :forbidden }
        end
      
      else
        @playlist.destroy

        respond_to do |format|
          format.json { head :no_content }
        end
      end
    end
  end
  
  # POST /playlists/1/track_positions
  # POST /playlists/1/track_positions.json
  def track_positions
    Playlist.transaction do
      Track.transaction do
        @playlist = Playlist.find(params[:id])

        if @playlist.user != current_user
          logger.warn "[playlists] Attempt to update Playlist's ##{params[:id]} tracks without permission: playlist does not belong to the user"
          respond_to do |format|
            format.json { head :forbidden }
          end
          return
        end
          
        tracks_count = @playlist.tracks.where(["tracks.id IN (?)", params[:positions]]).count
        if tracks_count != params[:positions].size
          logger.warn "[playlists] Attempt to update Playlist's ##{params[:id]} tracks without permission: some of the tracks does not belong to the user or does not exist in the database, requested IDs length is #{params[:positions].size}, DB IDs length is #{tracks_count}"
          respond_to do |format|
            format.json { head :forbidden }
          end
          return
        end
        
        params[:positions].each_with_index do |track_id, new_position|
          Track.where(:id => track_id.to_i).update_all(:position => new_position)
        end

        respond_to do |format|
          format.json { head :no_content }
        end
      end
    end
  end
end
