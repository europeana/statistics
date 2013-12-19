class Core::Oauth < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :core_oauths
  
  #ACCESSORS
  attr_accessible :user_id, :app, :created_by, :refresh_token, :token, :token_expires_at, :updated_by, :name, :email
  
  #ASSOCIATIONS
  has_many :data_ga_accounts, class_name: "Data::GaAccount", dependent: :destroy, foreign_key: "core_oauth_id"
  belongs_to :creator, class_name: "User", foreign_key: "created_by"
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  belongs_to :user
  
  #VALIDATIONS
  #CALLBACKS
  before_create :before_create_set
  after_create  :after_create_set
  
  #SCOPES
  scope :ga, where(app: "GA")
  
  #CUSTOM SCOPES
  #OTHER METHODS
  
  def reauthenticate?
    if Time.now - self.token_expires_at > 0
      j = GRuby::Auth.refresh(self.refresh_token)
      self.update_attributes(token: j["access_token"], token_expires_at: Time.now + j["expires_in"])
    end
    true
  end
      
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_create_set
    self.created_by = User.current.id   if self.id.blank?
    self.updated_by = User.current.id
    true
  end
  
  def after_create_set
    if app == "GA"
      Data::GaAccount.get_accounts(self)
    end
  end
  
end
