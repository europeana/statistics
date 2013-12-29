class Cms::Image < ActiveRecord::Base
  
  #GEMS USED
  self.table_name = :cms_images
  extend FriendlyId
  friendly_id :title, use: [:slugged]
  
  mount_uploader :image_file, ImageUploader
  
  #ACCESSORS
  attr_accessible :slug, :image_file, :title, :url
  
  #ASSOCIATIONS
  #VALIDATIONS
  validate :title, presence: true, uniqueness: true, length: {minimum: 2}
  validates :image_file, :presence => true
  
  #CALLBACKS  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS  
  #UPSERT
  #JOBS
  #PRIVATE
  private
    
end
