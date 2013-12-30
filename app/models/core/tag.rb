class Core::Tag < ActiveRecord::Base
  attr_accessible :description, :genre, :name, :slug
end
