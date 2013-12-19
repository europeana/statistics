class Account < ActiveRecord::Base
  
  #GEMS USED
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :creator
  has_paper_trail

  #ACCESSORS
  attr_accessible :name, :description, :created_by, :updated_by, :license, :domain, :api_token

  #ASSOCIATIONS
  belongs_to :creator, class_name: "User", foreign_key: "created_by"
  belongs_to :updator, class_name: "User", foreign_key: "updated_by"
  has_many :permissions, dependent: :destroy
  has_many :users, through: :permissions
  has_many :core_visits, class_name: "Core::Visit", dependent: :destroy
  has_many :core_alerts, class_name: "Core::Alert"
  has_many :core_files, class_name: "Core::File", dependent: :destroy

  #VALIDATIONS
  validates :name, presence: true, length: {minimum: 5}, on: :create
  validate :is_name_unique?, on: :create
  validates_format_of :domain, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix, allow_blank: true

  #CALLBACKS
  after_create :after_create_set
  before_create :before_create_set
  before_save :before_save_set
  after_update :after_update_set
  
  #SCOPES
  #CUSTOM SCOPES
  def owner
    self.permissions.owner.first.user
  end
  
  #OTHER METHODS  
  #UPSERT
  #JOBS
  #PRIVATE 
  private
  
  def is_name_unique?
    if User.current.accounts.where(name: self.name).first.present?
      errors.add(:name, "already taken")
    end
  end
  
  def after_create_set
    Permission.create!(user_id: self.created_by, account_id: self.id, role: "O", email: self.creator.email)
    Core::Alert.log(self.id, "created")
    Core::File.create!(account_id: self.id, genre: "readme", file_content_type: "md", file_file_name: "README.md")
    Core::File.create!(account_id: self.id, genre: "license", file_content_type: "md", file_file_name: "License.md", category: self.license)
    true
  end
  
  def after_update_set
    Core::Alert.log(self.id, "updated")
    if self.license_changed?
      self.core_files.license.first.update_attributes(category: self.license)
    end
    true
  end
  
  def before_save_set
    self.created_by = User.current.id   if self.id.blank?
    self.updated_by = User.current.id
    true
  end

  def before_create_set
    self.api_token = SecureRandom.hex
    true
  end

end
