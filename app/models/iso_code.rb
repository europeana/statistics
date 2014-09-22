class IsoCode < ActiveRecord::Base
  attr_accessible :code, :country

  def self.seed
    File.open("iso/isocode.csv").each do |line|
      country_codes = line.split(",")
      code = country_codes[0]
      country = country_codes[1]
      IsoCode.find_or_create_by_code_and_country(code,country)
    end
  end
  
end
