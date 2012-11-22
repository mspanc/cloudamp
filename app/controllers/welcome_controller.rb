class WelcomeController < ApplicationController
  layout "welcome"
  
  def index
    redirect_to main_player_url if user_signed_in?
  end
end
