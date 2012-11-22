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
                                   :redirect_uri  => initialize_session_authentication_url   
    end
    @soundcloud
  end
end
