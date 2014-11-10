class Setting < ActiveRecord::Base
  attr_accessible :masonry, :image, :header_name, :page_builder_config

  mount_uploader :image, ImageUploader2

end
