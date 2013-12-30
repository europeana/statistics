class Core::Tag < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :core_tags

  extend FriendlyId
  friendly_id :name, use: [:slugged]
  
  #ACCESSORS
  attr_accessible :description, :genre, :name, :slug

  #ASSOCIATIONS
  #VALIDATIONS
  validates :name, presence: true
  #validates :genre , presence: true
  validate :validate_uniqueness?

  #CALLBACKS
  before_create :before_create_set
  
  #SCOPES  
  #CUSTOM SCOPES
  #OTHER METHODS  
  #JOBS
  #PRIVATE
  private
  
  def validate_uniqueness?
    self.genre = "Page"
    dup = Core::Tag.where(name: self.name, genre: self.genre).first
    if dup.present?
      errors.add(:name, "already taken for this genre")
    end
  end
  
  def before_create_set
    self.genre = "Page"
  end
  
end
