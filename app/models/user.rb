class User < ActiveRecord::Base
  
  #GEMS USED
  #ACCESSORS
  attr_accessible :email, :password, :remember_me, :name, :authentication_token, :bio, :time_zone, :username, :url, :company, :location, :gravatar_email, :public_email

  #ASSOCIATIONS
  #VALIDATIONS
  #CALLBACKS  
  before_save :encrypt_password
  #SCOPES  
  #CUSTOM SCOPES
  #OTHER METHODS

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(email, password)
    user = find_by_email_id(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)      
      user      
    else
      nil
    end
  end  

  #UPSERT  
  #JOBS
  #PRIVATE
  private
      
end
