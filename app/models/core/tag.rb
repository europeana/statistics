class Core::Tag < ActiveRecord::Base
  attr_accessible :description, :genre, :name, :taggable_id, :taggable_type
end
