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
      JSON.parse("[[\"Data\", \"string\"],[\"Size\", \"number\"]]").invert
    elsif self.chart == "Grouped Column Chart" or self.chart == "Stacked Column Chart"
      JSON.parse("[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"],[\"Group\", \"string\"]]").invert
    else
      JSON.parse("[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"]]").invert
    end
  end
  
  #UPSERT
  #JOBS
  #PRIVATE
  private
  
  def before_save_set
    if self.map.present?      
      headings = raw_data.shift
      headings = headings.collect{|h| h.split(":").first}
      mapped_output = [{"key" => "Chart","values" => []}] #json_data
      if self.chart == "Pie Chart" or self.chart == "Election Donut Chart" or self.chart == "Donut Chart"
        self.mapped_output = self.mapper_1d(headings)    
      elsif self.chart == "Grouped Column Chart" or self.chart == "Stacked Column Chart"
        true
      else
        true
      end
    end      
    true
  end
    
  def mapper_1d(headings)
    JSON.parse(self.data_filz.content).each do |row|
      h = {}
      label = row[headings.index(reference_map["Dimension"])]
      value = row[headings.index(reference_map["Size"])]
      el = false
      transformed_data[0]["values"].each_with_index do |set, i|
        if set["label"] == label
          el = i
        end
      end
      unless el
        h["label"] = label
        h["value"] = value.to_i
        transformed_data[0]["values"].push(h);
      else
        hash = transformed_data[0]["values"][el]
        hash["value"] += value.to_i
        transformed_data[0]["values"][el] = hash
      end
      if h != {}
        transformed_data[0]["values"].push(h);
      end
    end
    transformed_data.to_json
  end
  
end
