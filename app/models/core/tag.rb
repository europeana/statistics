class Core::Tag < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :core_tags

  extend FriendlyId
  friendly_id :name, use: [:slugged]
  
  #ACCESSORS
  attr_accessible :description, :genre, :name, :slug, :sort_order

  #ASSOCIATIONS
  has_many :cms_articles, foreign_key: :core_tag_id, class_name: "Cms::Article"
  
  #VALIDATIONS
  validates :name, presence: true
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
    dup = Core::Tag.where(name: self.name, genre: "Pages").first
    if (dup.present? and self.id.blank?) or (dup.present? and self.id.present? and dup.id != self.id)
      errors.add(:name, "already taken for this genre")
    end
  end
  
  def before_create_set
    self.genre = "Pages" if self.genre.blank?
    self.sort_order = Core::Tag.select("max(sort_order) as max").first.max.to_i + 1 if self.sort_order.blank?
    true
  end
  
end
