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
end
