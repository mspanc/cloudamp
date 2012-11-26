class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  protected
  
  # Helper function that returns SoundClound client object.
  #
  # Ensures that it is initialized only once. 
  def soundcloud
    unless @soundcloud 
      @soundcloud = Soundcloud.new :client_id     => Settings.soundcloud.app.client_id,
                                   :client_secret => Settings.soundcloud.app.client_secret,
                                   :redirect_uri  => new_session_url   
    end
    @soundcloud
  end
  
  
  def current_user
    return @current_user if @current_user
    
    if session[:user_id]
      @current_user = User.find(session[:user_id]) 
      @current_user
    else
      nil
    end
      
    rescue ActiveRecord::RecordNotFound
      nil
  end
  
  def user_signed_in?
    not current_user.nil?
  end

  def authenticate_user_with_forced_forbidden
    perform_authenticate_user true
  end
  
  def authenticate_user
    perform_authenticate_user false
  end
  
  
  def perform_authenticate_user(forced_forbidden)
    unless user_signed_in?
      # Clean up the session 
      reset_session

      # Log the error and inform the user 
      logger.warn "[initialize_session] Trying to access site without signing in"
      flash[:error] = "You must be signed in to use the player."
      
      # Go back to the home page
      respond_to do |format|
        format.html do 
          if forced_forbidden
            render :text => "403", :status => 403
          else
            redirect_to root_url 
          end
        end
        format.json { head :forbidden }
      end
    end
  end      
end
