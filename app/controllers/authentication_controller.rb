#
# This controller handles SoundCloud authentication process.
#
# It uses procedure described in SoundCloud API docs 
# as "Server-side Web Applications".
#
# See http://developers.soundcloud.com/docs#authentication
# for more information.
# 
class AuthenticationController < ApplicationController
  layout false
  
  # Redirects to SoundCloud's sign in form.
  #
  # After successful sign in user will be redirected back to the app,
  # please refer to AuthenticationController#initialize_session for 
  # more information.
  def redirect
    redirect_to soundcloud.authorize_url
  end
  
  
  # Handles successful sign in to SoundCloud.
  #
  # Retreives access token, stores it and then fetches user information
  # in order to find or create database entries used later on to store
  # playlists.
  #
  # Then redirects to the main player interface.
  #
  # * *Parameters*    :
  #   - +code+ -> code used to retreive access token
  #   - +expires_in+ -> code expiration time
  #   - +scope+ -> code's scope
  def initialize_session
    # Get access token from SoundCloud and save it for use in the player
    session[:soundcloud_access_token] = soundcloud.exchange_token(:code => params[:code]).access_token
    
    # Fetch information about SoundCloud user
    me = soundcloud.get('/me')

    # Find or create User account associated with this SoundCloud account   
    current_user = User.find_or_create_by_soundcloud_id me.id

    # Store necessary user information
    session[:soundcloud_username] = me.username
    session[:user_id] = current_user.id
    
    # Redirect to the main player view
    redirect_to main_player_url
      

    # Handle cases when API is not responding
    rescue Soundcloud::ResponseError => e
      # Log the error and inform the user     
      logger.warn "[initialize_session] SoundCloud replied with error: #{e}, parameters were: #{params.inspect}"
      flash[:error] = "We are unable to connect with your SoundCloud account. Please try again."
      
      # Clean up the session 
      reset_session
      
      # Go back to the home page
      redirect_to root_url
      
    
    # Handle other errors
    rescue
      # Log the error and inform the user 
      logger.warn "[initialize_session] Error #{$!.class}: #{$!}, parameters were: #{params.inspect}"
      flash[:error] = "We've encountered an internal server error while connecting with your SoundCloud account. Please try again."

      # Clean up the session 
      reset_session
      
      # Go back to the home page
      redirect_to root_url
       
  end
end
