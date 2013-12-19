class CoreOauthsController < ApplicationController
    
  before_filter :authenticate_user!
  
  def revalidate
    #@dashboard = Dashboard.find(params[:did])
    redirect_to "https://accounts.google.com/o/oauth2/auth?response_type=code&access_type=offline&approval_prompt=auto&client_id=#{GOOGLE_CLIENTID}&redirect_uri=#{GOOGLE_CALLBACK}&scope=https://www.googleapis.com/auth/analytics.readonly&state=#{@dashboard.id}"
  end
  
  def create
    j = GRuby::Auth.token(params[:code])
    a = current_user.core_oauths.ga.where(refresh_token: j["refresh_token"]).first
    if j["refresh_token"].present? and a.blank?
      a = Core::Oauth.new(user_id: current_user.id, app: "GA", refresh_token: j["refresh_token"])
    end
    a.token = j["access_token"]
    a.token_expires_at = Time.now + j["expires_in"]
    a.save
    redirect_to integrations_user_path, notice: "Authentication successful."
  end
  
end
