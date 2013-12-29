class Data::Filz < ActiveRecord::Base

  #GEMS USED
  require 'csv'
  self.table_name = :data_filzs

  extend FriendlyId
  friendly_id :file_file_name, use: [:slugged]
  
  #ACCESSORS
  attr_accessible :content, :genre, :file_file_name, :core_oauth_id

  #ASSOCIATIONS
  belongs_to :core_oauth, class_name: "Core::Oauth", foreign_key: "core_oauth_id"

  #VALIDATIONS
  validate :file_file_name, presence: true, uniqueness: true, length: {minimum: 2}
  validates :content, length: {minimum: 5, message: "is too short (minimum is 5 rows)"}, allow_blank: true

  #CALLBACKS
  before_save :before_save_set

  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_save_set    
    if self.content.present?
      con = self.content.class.to_s == "String" ? JSON.parse(self.content) : self.content
      con.delete_if{ |row| row.flatten.compact.empty? }
      new_header = Data::FilzColumn.get_headers(con)
      newa = []
      newa = [new_header.split(",")] + con
      con = newa
      self.content = con.to_json
    end
    true
  end

end