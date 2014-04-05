class ApplicationController < ActionController::Base
  
  include ApplicationHelper
  #SECURITY
  #protect_from_forgery
  helper_method :current_user
  
  #GEMS  
  #CALLBACKS
  after_filter :after_filter_set

  #PRIVATE
  private

  def after_filter_set
    #set_access_control_headers madhukaudantha.blogspot.in/2011/05/access-control-allow-origin-in-rails.html
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end
  
  def authenticate_user!
    if session[:user_id].blank?
      redirect_to root_url, notice:"Please login first"  
    end
  end
 
  def current_user
     @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
  end
  
  def signed_in?
    current_user.blank?
  end
    
end
