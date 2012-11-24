class TracksController < ApplicationController
  before_filter :authenticate_user
  
  # POST /tracks
  # POST /tracks.json
  def create
    @track = Track.new(params[:track])
    
    if @track.playlist.user != current_user
      logger.warn "[tracks] Attempt to create Track that will belong to Playlist ##{params[:track][:playlist_id]} without permission"
      respond_to do |format|
        format.json { head :forbidden }
      end

    else
      respond_to do |format|
        if @track.save
          format.json { render json: @track, status: :created, location: @track }
        else
          format.json { render json: @track.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PUT /tracks/1
  # PUT /tracks/1.json
  def update
    @track = Track.find(params[:id])

    if @track.playlist.user != current_user
      logger.warn "[tracks] Attempt to update Track ##{params[:id]} that belongs to Playlist ##{@track.playlist.id} without permission"
      respond_to do |format|
        format.json { head :forbidden }
      end
    else
      respond_to do |format|
        if @track.update_attributes(params[:track])
          format.json { head :no_content }
        else
          format.json { render json: @track.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.json
  def destroy
    @track = Track.find(params[:id])

    if @track.playlist.user != current_user
      logger.warn "[tracks] Attempt to delete Track ##{params[:id]} that belongs to Playlist ##{@track.playlist.id} without permission"
      respond_to do |format|
        format.json { head :forbidden }
      end
    else
      @track.destroy

      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end
end
