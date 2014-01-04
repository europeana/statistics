class Viz::Viz < ActiveRecord::Base

  #GEMS USED
  self.table_name = :viz_vizs
  extend FriendlyId
  friendly_id :title, use: [:slugged]
  
  require 'json'
  require 'csv'
  
  #BAR - First two columns, first column is Y axis and two column is X axis
  #COLUMN - First two columns, first column is X axis and two column is Y axis
  #COLUMN / STACKED - Three columns
  #LINE - at least 2 columns
  
  #CONSTANTS
  CHARTS = [["Pie Chart"], ["Election Donut Chart"], ["Donut Chart"], ["Bar Chart"], ["Column Chart"], ["Grouped Column Chart"], ["Line Chart"]]

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
      [["Dimension", "string", "m"],["Size", "number", "m"]]
    elsif self.chart == "Bar Chart"
      [["X", "number", "m"], ["Y", "string", "m"]]
    elsif self.chart == "Column Chart"
      [["X", "string", "m"],["Y", "number", "m"]]
    elsif self.chart == "Grouped Column Chart"
      [["X", "string", "m"],["Y", "number", "m"],["Group", "string", "m"]]
    elsif self.chart == "Stacked Column Chart"
      [["X", "string", "m"],["Y", "number", "m"],["Stack", "string", "m"]]
    elsif self.chart == "Line Chart"
      [["X", "string", "m"],["Line 1", "number", "m"],["Line 2", "number", "o"],["Line 3", "number", "o"],["Line 4", "number", "o"]]
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
