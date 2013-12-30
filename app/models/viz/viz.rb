class Viz::Viz < ActiveRecord::Base

  #GEMS USED
  self.table_name = :viz_vizs
  extend FriendlyId
  friendly_id :title, use: [:slugged]
  
  require 'json'
  require 'csv'
  
  #CONSTANTS
  CHARTS = [["Pie Chart"], ["Election Donut Chart"], ["Donut Chart"], ["Bar Chart"], ["Column Chart"], ["Grouped Column Chart"], [], ["Line Chart"]]

  #ACCESSORS
  attr_accessible :data_filz_id, :map, :mapped_output, :settings, :title, :slug, :chart

  #ASSOCIATIONS
  belongs_to :data_filz, class_name: "Data::Filz", foreign_key: "data_filz_id"

  #VALIDATIONS
  validate :title, presence: true, uniqueness: true, length: {minimum: 2}
  validates :data_filz_id, presence: :true
  validates :map, presence: :true, on: :update

  #CALLBACKS
  before_save :before_save_set

  #SCOPES
  #CUSTOM SCOPES
  #OTHER METHODS
  
  def headers
    JSON.parse(self.data_filz.content)[0]
  end

  def reference_map
    if self.chart == "Pie Chart" or self.chart == "Election Donut Chart" or self.chart == "Donut Chart"
      [["Dimension", "string"],["Size", "number"]]
    elsif self.chart == "Grouped Column Chart" or self.chart == "Stacked Column Chart"
      [["X", "number"],["Y", "number"],["Size", "number"],["Group", "string"]]
    else
      [["X", "number"],["Y", "number"],["Size", "number"]]
    end
  end
  
  def mapper_1d(headings, map_json, raw_data)
    transformed_data = [{"key" => "Chart","values" => []}] #json_data
    h = {}
    out = []
    raw_data.each do |row|
      label = row[headings.index(map_json["Dimension"])]
      value = row[headings.index(map_json["Size"])]
      h[label] = h[label].present? ? (h[label].to_f + value.to_f) : value.to_f
    end
    if h != {}
      h.each do |key, val|
        out << [key, val]
      end
      transformed_data[0]["values"].push(out)
    end  
    transformed_data.to_json
  end
  
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_save_set
    if self.map.present?     
      raw_data = JSON.parse(self.data_filz.content) 
      headings = raw_data.shift
      headings = headings.collect{|h| h.split(":").first}
      mapped_output = [{"key" => "Chart","values" => []}] #json_data
      map_json = JSON.parse(self.map).invert
      if self.chart == "Pie Chart" or self.chart == "Election Donut Chart" or self.chart == "Donut Chart"
        self.mapped_output = mapper_1d(headings, map_json, raw_data)    
      elsif self.chart == "Grouped Column Chart" or self.chart == "Stacked Column Chart"
        true
      else
        true
      end
    end      
    true
  end
  
end
