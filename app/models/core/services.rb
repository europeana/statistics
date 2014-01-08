class Core::Services
  
  #Core::Services.twod_to_csv(twod_array)
  def self.twod_to_csv(twodarray, options = {})
    CSV.generate(options) do |csv|
      twodarray.each do |row|
        csv << row
      end
    end
  end
  
  #Core::Services.end_of_month(month, year)
  def self.end_of_month(month, year)
    Date.new(year, month, -1).to_time + 86340
  end
  
  #Core::ga_date_format(d)
  def self.ga_date_format(d)
    mon = d.month.to_s.length == 1 ? "0#{d.month.to_s}" : d.month.to_s
    day = d.day.to_s.length == 1 ? "0#{d.day.to_s}" : d.day.to_s
    "#{d.year.to_s}-#{mon}-#{day}"
  end
  
  #Core::Services.array_of_array_to_handsontable(array_of_array)
  def self.array_of_array_to_handsontable(array_of_array)
    output = []
    array_of_array.each do |array|
      internal_array = []
      array.each do |a|
        internal_array << a.to_s.gsub('"', "'")
      end
      output << internal_array
    end
    output
  end
  
  #Core::Services.get_json(nestful_response)
  def self.get_json(nestful_response)
    begin
      if !nestful_response.blank?
        if !nestful_response.body.blank?
          return JSON.parse(nestful_response.body)
        end
      end
      return nil
    rescue
      return nil
    end
  end
  
  #Core::Services.basic_auth(url, username, password, user_agent)
  def self.basic_auth(url, username, password, user_agent)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => user_agent})
    request.basic_auth username, password
    response = http.request(request)
    return JSON.parse(response.body)
  end
    
end
