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
end
