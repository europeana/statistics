class Jobs::GaFirst
  
  def self.query(oauth_id)
    begin
      puts "start"
      
      oauth_id = 1
      core_oauth = Core::Oauth.find(oauth_id)
      
      sd = Date.new(2013, 11, 22)
      
      sd = Date.new(2010, 1, 1)
      ed = Core::Services.end_of_month(sd.month, sd.year)
      while ed < Date.today
        start_date = Core::Services.ga_date_format(sd)
        end_date = Core::Services.ga_date_format(ed)        
        puts "calling api for #{start_date} to #{end_date}"
        core_oauth.reauthenticate?
        api_output = core_oauth.ga_query2(start_date, end_date)
        puts "processing"
        final_output = Core::Services.array_of_array_to_handsontable(api_output)
        final_output.each do |j|
          j << j[0][0..3]
          j << j[0][4..5]
          j << j[0][6..7]
          j[0] = "#{j[0][0..3]}-#{j[0][4..5]}-#{j[0][6..7]}"
          j << j[2].split("/")[0].blank? ? nil : j[2].split("/")[0].strip
          j << j[2].split("/")[1].blank? ? nil : j[2].split("/")[1].strip
        end
        sd = ed.to_date + 1
        ed = Core::Services.end_of_month(sd.month, sd.year)
      end
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      data_filz = core_oauth.data_filz
      
      o = []
      o << Core::Oauth::HEADER_ROW.split(",") if data_filz.content.blank?
      o = o + final_output
      
      data_filz.update_attributes(:content => o)
    rescue Exception => ex
      puts "fail"
      puts ex.message
    end
  end
    
end