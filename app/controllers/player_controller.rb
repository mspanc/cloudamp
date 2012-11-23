class PlayerController < ApplicationController
  before_filter :authenticate_user
  
  def main

  end
  
  
  
  protected
  
  def authenticate_user
    
    # TODO
  end
end
