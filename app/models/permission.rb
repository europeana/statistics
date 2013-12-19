class Permission < ActiveRecord::Base
  
  #GEMS USED
  #ACCESSORS
  attr_accessible :account_id, :created_by, :role, :updated_by, :user_id, :email
  has_paper_trail

  #ASSOCIATIONS
  belongs_to :account
  belongs_to :user
  belongs_to :creator, class_name: "User", foreign_key: "created_by"
  belongs_to :updator, class_name: "User", foreign_key: "updated_by"  
  #notes: as: :excelable, :class_name => "ExcelService"

  #VALIDATIONS
  validates :email, :length => { :minimum => 5 }, format:  { :with => Pyk::Regex::EMAIL, :message => "invalid format"}, :presence => true
  validates :account_id, presence: true
  validate  :is_invite_unique?, on: :create
  
  #CALLBACKS
  before_create :before_create_set
  before_save :before_save_set
  after_create :after_create_set

  #SCOPES
  scope :owner, where(role: "O")
  scope :collaborators, where(role: "C")
  scope :collaborator_repo, -> email {where(email: email, role: "C") if email.present?} 
  scope :has_account, -> check {where(user_id: User.current.id ) if check} 
  
  #CUSTOM SCOPES
  #OTHER METHODS
  
  def name
    (self.user.blank? and self.email.present?) ? self.email : self.user.to_s
  end
  
  def email_to_s
    self.email.present? ? self.email : self.user.email
  end

  def _thumb
    Core::Services.gravatar(self.email, 20)
  end
  
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_save_set
    self.created_by = User.current.id   if self.id.blank?
    self.updated_by = User.current.id
    true
  end
  
  def before_create_set
    self.role       = "C"               if self.role.blank?
    true
  end
  
  def after_create_set
    Core::Alert.log(self.account_id, "new_user", "Permission", self.id)
    true
  end
  
  def is_invite_unique?
    if Permission.where(account_id: self.account_id, email: self.email).first.present?
      return errors.add(:email, "already invited.") 
    end 
  end

end
