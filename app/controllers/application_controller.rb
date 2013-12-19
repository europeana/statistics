class ApplicationController < ActionController::Base
  
  include ApplicationHelper
  #SECURITY
  protect_from_forgery
  
  #GEMS  
  #CALLBACKS
  
  #PRIVATE
  private
  def authenticate_user!
    if session[:username]
    else
      redirect_to root_url, notice:"Please login first"  
    end
  end
          
end
