class User < ActiveRecord::Base
  
  #GEMS USED
  #ACCESSORS
  attr_accessible :email, :password

  #ASSOCIATIONS
  has_many :api_oauths, class_name: "Api::Oauth", dependent: :destroy
  has_many :api_accounts, class_name: "Api::Account", dependent: :destroy

  #VALIDATIONS
  validates :email, uniqueness: {case_sensitive: false}, length: {minimum: 5}, format: {with: Pyk::Regex::EMAIL, message: "invalid format"}, presence: true
  validates :password , length: { within: 8..40, on: :create }, presence: {on: :create}

  #CALLBACKS
  before_save :encrypt_password
  
  #SCOPES  
  #CUSTOM SCOPES
  #OTHER METHODS  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user      
    else
      nil
    end
  end  
  
  #JOBS
  #PRIVATE
  private

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
    
end
