class PlaylistsController < ApplicationController
  # POST /playlists
  # POST /playlists.json
  def create
    @playlist = Playlist.new(params[:playlist])

    respond_to do |format|
      if @playlist.save
        format.json { render json: @playlist, status: :created, location: @playlist }
      else
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /playlists/1
  # PUT /playlists/1.json
  def update
    @playlist = Playlist.find(params[:id])

    respond_to do |format|
      if @playlist.update_attributes(params[:playlist])
        format.json { head :no_content }
      else
        format.json { render json: @playlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playlists/1
  # DELETE /playlists/1.json
  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
