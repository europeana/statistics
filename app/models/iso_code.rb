class IsoCode < ActiveRecord::Base
  attr_accessible :code, :country,:continent

  def self.seed
    IsoCode.destroy_all
    CSV.read("iso/countries.csv").each do |line|
      code = line[0]
      country = line[1]
      continent = line[2]  
      IsoCode.create!(code: code,country: country,continent: continent)
    end
  end
  
end
