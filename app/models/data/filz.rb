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
  has_many :viz_vizs, class_name: "Viz::Viz", foreign_key: "data_filz_id"

  #VALIDATIONS
  validate :file_file_name, presence: true, uniqueness: true, length: {minimum: 2}
  validates :content, length: {minimum: 5, message: "is too short (minimum is 5 rows)"}, allow_blank: true

  #CALLBACKS
  before_save :before_save_set
  after_update :after_update_set

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
  
  def after_update_set
    self.viz_vizs.each do |viz|
      if viz.map.present?     
        raw_data = JSON.parse(self.content) 
        headings = raw_data.shift
        headings = headings.collect{|h| h.split(":").first}
        map_json = JSON.parse(viz.map).invert
        viz.mapped_output = mapper(headings, map_json, raw_data)
        viz.save
      end
    end
    true
  end

end