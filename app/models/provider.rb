class Provider < ActiveRecord::Base
  attr_accessible :provider_type, :provider_id, :name
end
