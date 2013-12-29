class Jobs::Ga
  
  def self.query(oauth_id, scope)
    begin
      if scope == "today"
        d = Date.today - 1
        start_date = "#{d.year.to_s}-#{d.month.to_s}-#{d.day.to_s}"
        end_date = start_date
      else
        d = Date.today - 30
        start_date = "#{d.year.to_s}-#{d.month.to_s}-#{d.day.to_s}"
        d = Date.today - 1
        end_date = "#{d.year.to_s}-#{d.month.to_s}-#{d.day.to_s}"
      end
      core_oauth = Core::Oauth.find(oauth_id)
      core_oauth.reauthenticate? #get the token
      api_output = core_oauth.ga(start_date, end_date) #calling the API
      final_output = Core::Services.array_of_array_to_handsontable(api_output) #transforming the data
      
      #add more calculated data points
      final_output.each do |j|
        j << j[0][0..3]
        j << j[0][4..5]
        j << j[0][6..7]
        j[0] = "#{j[0][0..3]}-#{j[0][4..5]}-#{j[0][6..7]}"
        j << j[2].split("/")[0].strip
        j << j[2].split("/")[1].strip
      end
      
      data_filz = core_oauth.data_filz
      
      o = []
      o << Core::Oauth::HEADER_ROW.split(",") if data_filz.content.blank?
      o = o + final_output
      
      data_filz.update_attributes(:content => o)
    rescue Exception => ex
      
    end
  end
    
end