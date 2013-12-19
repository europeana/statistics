class User < ActiveRecord::Base
  
  #GEMS USED
  #ACCESSORS
  attr_accessible :email, :password, :remember_me, :name, :authentication_token, :bio, :time_zone, :username, :url, :company, :location, :gravatar_email, :public_email

  #ASSOCIATIONS
  #VALIDATIONS
  #CALLBACKS  
  #SCOPES  
  #CUSTOM SCOPES
  #OTHER METHODS
  #UPSERT  
  #JOBS
  #PRIVATE
  private
      
end
