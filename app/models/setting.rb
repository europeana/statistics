class Setting < ActiveRecord::Base
  attr_accessible :masonry, :image, :header_name

  mount_uploader :image, ImageUploader2

end
