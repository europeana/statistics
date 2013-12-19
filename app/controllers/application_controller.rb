class ApplicationController < ActionController::Base
  
  include ApplicationHelper
  #SECURITY
  protect_from_forgery
  
  #GEMS  
  #CALLBACKS
  before_filter :before_filter_set
  after_filter :after_filter_set
  around_filter :user_time_zone, if: :current_user
  
  #PRIVATE
  private

  def before_filter_set
    #ui attributes
    hacks = !(controller_name == "static_pages" and action_name == "campaigns")
    @is_breadcrumb_enabled = (current_user.blank? and hacks) ? false : true
    
    #find objects
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      if params[:account_id].present? 
        @account = Account.joins(:permissions).where(permissions: {role: "O", user_id: @user.id}).first
        @users_count = @account.permissions.count
      end
      if @account.present? and current_user.present?
        @is_admin = @account.permissions.owner.where(user_id: current_user.id).first.present? ? true : false
      end
    end
    
    #log_visit
    Core::Visit.log(request, current_user, @account)
    
    #Current user data setting from session to use in model
    if current_user.present?
      User.current = current_user 
    end
  end
  
  def after_filter_set
    #set_access_control_headers madhukaudantha.blogspot.in/2011/05/access-control-allow-origin-in-rails.html
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end
  
  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
    
end
