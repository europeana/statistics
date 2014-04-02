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
  CHARTS = [ ["Pie Chart"], ["Election Donut Chart"],
             ["Column Chart"], ["Grouped Column Chart"],
             ["Line Chart"], ["Stacked Column Chart"],
             ["Bubble Chart"], ["Compare Line Chart"], ["Bullet Chart"]]

  #ACCESSORS
  attr_accessible :data_filz_id, :map, :mapped_output, :settings, :title, :slug, :chart

  #ASSOCIATIONS
  belongs_to :data_filz, class_name: "Data::Filz", foreign_key: "data_filz_id"

  #VALIDATIONS
  validates :title, presence: true, uniqueness: true, length: {minimum: 2}
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
    if self.chart == "Pie Chart" or self.chart == "Election Donut Chart" or self.chart == "Donut Chart" or self.chart == "Bubble Chart"
      [["Dimension", "string", "M"],["Size", "number", "M"]]
    elsif self.chart == "Bar Chart"
      [["X", "number", "M"], ["Y", "string", "M"]]
    elsif self.chart == "Column Chart"
      [["X", "string", "M"],["Y", "number", "M"]]
    elsif self.chart == "Grouped Column Chart"
      [["X", "string", "M"],["Y", "number", "M"],["Group", "string", "M"]]
    elsif self.chart == "Stacked Column Chart"
      [["X", "string", "M"],["Y", "number", "M"],["Stack", "string", "M"]]
    elsif self.chart == "Line Chart"
      [["X", "string", "M"],["Line 1", "number", "M"]]#,["Line 2", "number", "O"],["Line 3", "number", "O"],["Line 4", "number", "0"]]
    elsif self.chart == "Compare Line Chart"
      [ ["X", "string", "M"],["Monthly", "number", "M"],
        ["Quaterly", "number", "O"],["Yearly", "number", "O"],
        ["All", "number", "0"]
      ]
    elsif self.chart == "Bullet Chart"
      [ ["X", "string", "M"],["Subtitle", "string", "M"],
        ["Ranges", "string", "O"],["Measures", "string", "O"],
        ["Markers", "string", "0"]
      ]
    end
  end
  
  def mapper(headings, map_json, raw_data)
    transformed_data = []    
    h = {}
    h["row-headings"] = map_json
    out = []
    raw_data.each do |row|
      if self.chart == "Pie Chart" or self.chart == "Election Donut Chart" or self.chart == "Donut Chart" or self.chart == "Bubble Chart"
        label = row[headings.index(map_json["Dimension"])]
        value = row[headings.index(map_json["Size"])]
      elsif self.chart == "Bar Chart"
        label = row[headings.index(map_json["Y"])]
        value = row[headings.index(map_json["X"])]
      elsif self.chart == "Column Chart"
        label = row[headings.index(map_json["X"])]
        value = row[headings.index(map_json["Y"])]
      elsif self.chart == "Grouped Column Chart"
        label = row[headings.index(map_json["X"])]
        value = row[headings.index(map_json["Y"])]
        group = row[headings.index(map_json["Group"])]
      elsif self.chart == "Stacked Column Chart"
        label = row[headings.index(map_json["X"])]
        value = row[headings.index(map_json["Y"])]
        stack = row[headings.index(map_json["Stack"])]
      elsif self.chart == "Line Chart"
        label = row[headings.index(map_json["X"])]
        value = row[headings.index(map_json["Line 1"])]
        #line2 = row[headings.index(map_json["Line 2"])]
        #line3 = row[headings.index(map_json["Line 3"])]
        #line4 = row[headings.index(map_json["Line 4"])]
      elsif self.chart == "Compare Line Chart"
        label = row[headings.index(map_json["X"])]
        value = row[headings.index(map_json["Monthly"])]
        line2 = row[headings.index(map_json["Quaterly"])]
        line3 = row[headings.index(map_json["Yearly"])]
        line4 = row[headings.index(map_json["All"])]
      elsif self.chart == "Bullet Chart"
        label = row[headings.index(map_json["X"])]
        value = row[headings.index(map_json["Subtitle"])]
        value2= row[headings.index(map_json["Ranges"])]
        value3= row[headings.index(map_json["Measures"])]
        value4= row[headings.index(map_json["Markers"])]
      end
      if self.chart == "Pie Chart" or self.chart == "Election Donut Chart" or self.chart == "Donut Chart" or self.chart == "Bar Chart" or self.chart == "Column Chart" or self.chart == "Line Chart" or self.chart == "Bubble Chart"
        unique_label = label
        if h[unique_label].present?
          h[unique_label] = {"label" => label, "value" => h[unique_label]["value"].to_f + value.to_f}
        else
          h[unique_label] = {"label" => label, "value" => value.to_f}
        end
      elsif self.chart == "Grouped Column Chart"
        unique_label = "#{label}#{group}"
        if h[unique_label].present?
          h[unique_label] = {"label" => label, "value" => h[unique_label]["value"].to_f + value.to_f, "group" => group}
        else
          h[unique_label] = {"label" => label, "value" => value.to_f, "group" => group}
        end
      elsif self.chart == "Stacked Column Chart"
        unique_label = "#{label}#{stack}"
        if h[unique_label].present?
          h[unique_label] = {"label" => label, "value" => h[unique_label]["value"].to_f + value.to_f, "stack" => stack}
        else
          h[unique_label] = {"label" => label, "value" => value.to_f, "stack" => stack}
        end        
      elsif self.chart == "Compare Line Chart"
        unique_label = label
        if h[unique_label].present?          
          h[unique_label] = {"label" => label,
           "value" => h[unique_label]["Monthly"].to_f + value.to_f,
           "line2" => h[unique_label]["Quaterly"].to_f + line2.to_f,
           "line3" => h[unique_label]["Yearly"].to_f + line3.to_f,
           "line4" => h[unique_label]["All"].to_f + line4.to_f
         }
        else
          h[unique_label] = {"label" => label,
           "value" => value.to_f,           
           "line2" => line2.to_f,
           "line3" => line3.to_f,
           "line4" => line4.to_f
          }
        end
      elsif self.chart == "Bullet Chart"  
        unique_label = label
        if h[unique_label].present?          
          h[unique_label] = {"label" => label,
           "value"  => h[unique_label]["Subtitle"],
           "value2" => h[unique_label]["value2"],
           "value3" => h[unique_label]["value3"],
           "value4" => h[unique_label]["value4"]
         }
        else
          h[unique_label] = {"label" => label,
           "value" => value,           
           "line2" => value2,
           "line3" => value3,
           "line4" => value4
          }
        end        
      end
    end
    if h != {}
      h.each do |unique_label, val|
        new_out = []
        val.each do |label, value|
          new_out << value
        end
        out << new_out
      end
      transformed_data << out
    end  
    transformed_data[0].to_json
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
      map_json = JSON.parse(self.map).invert
      self.mapped_output = mapper(headings, map_json, raw_data)    
    end      
    true
  end
  
end
