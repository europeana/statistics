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
  validate :title, presence: true, length: {minimum: 2}
  validates :image_file, :presence => true
  validate :is_name_unique?  
  
  #CALLBACKS  
  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS  
  #UPSERT
  #JOBS
  #PRIVATE
  private  
  def is_name_unique?
    g = Cms::Image.where(title: self.title).first
    if g.present?
      if g.id != self.id or self.id.blank?
        errors.add(:title, "already taken. --> #{g.image_file_url}" )
      end
    end
  end

    
end
