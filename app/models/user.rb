class User < ActiveRecord::Base
  
  #GEMS USED
  extend FriendlyId
  friendly_id :username, use: :slugged
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable
  has_paper_trail

  #ACCESSORS
  attr_accessible :email, :password, :remember_me, :name, :authentication_token, :bio, :time_zone, :username, :url, :company, :location, :gravatar_email, :public_email

  #ASSOCIATIONS
  has_many :permissions, dependent: :destroy
  has_many :accounts, through: :permissions
  has_many :core_oauths, class_name: "Core::Oauth", dependent: :destroy
  has_many :data_ga_accounts, class_name: "Data::GaAccount", dependent: :destroy

  #VALIDATIONS
  validates :email, uniqueness: {case_sensitive: false}, length: {minimum: 5}, format: {with: Pyk::Regex::EMAIL, message: "invalid format"}, presence: true
  validates :username, presence: true, length: {minimum: 5}
  validates_format_of :username, :with => /^[A-Za-z\d_]+$/
  validates :password , length: { within: 8..40, on: :create }, presence: {on: :create}
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix, allow_blank: true
  validates_format_of :gravatar_email, :with => Pyk::Regex::EMAIL, message: "invalid format", allow_blank: true
  validates_format_of :public_email, :with => Pyk::Regex::EMAIL, message: "invalid format", allow_blank: true

  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES  
  #CUSTOM SCOPES
  #OTHER METHODS
  # Current user data setting from session to use in model  
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end
  
  def my_accounts
    Account.joins(:permissions).where(permissions: {role: "O", user_id: self.id})
  end
  
  def shared_accounts
    Account.joins(:permissions).where(permissions: {role: "C", user_id: self.id})
  end

  #UPSERT
  def gravatar(size=20)
    Core::Services.gravatar(self.gravatar_email, size)
  end
  
  def to_s
    self.username
  end
  
  #JOBS
  #PRIVATE
  private
  
  def before_create_set
    self.authentication_token = SecureRandom.hex #set a secure random API key to each user
    self.time_zone = "Mumbai" 
    self.gravatar_email = self.email
    self.public_email = self.email
    true
  end
    
end
