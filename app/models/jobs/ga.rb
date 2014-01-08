class Jobs::Ga
  
  def self.query(oauth_id, sd)
    begin
      start_date = Core::Services.ga_date_format(sd)
      end_date = Core::Services.ga_date_format(sd)
      
      puts "calling api"
      core_oauth = Core::Oauth.find(oauth_id)
      core_oauth.reauthenticate? #get the token

      qry = "&metrics=ga:visitors,ga:newVisits,ga:visits,ga:bounces,ga:avgTimeOnSite,ga:pageviewsPerVisit,ga:pageviews,ga:avgTimeOnPage,ga:exits&dimensions=ga:date,ga:country,ga:sourceMedium,ga:keyword,ga:deviceCategory,ga:pagePath,ga:landingPagePath"
      api_output = core_oauth.ga(qry, start_date, end_date) #calling the API
      
      puts "processing"
      final_output = Core::Services.array_of_array_to_handsontable(api_output) #transforming the data
      
      #add more calculated data points
      final_output.each do |j|
        j << j[0][0..3]
        j << j[0][4..5]
        j << j[0][6..7]
        j[0] = "#{j[0][0..3]}-#{j[0][4..5]}-#{j[0][6..7]}"
        j << j[2].split("/")[0].blank? ? nil : j[2].split("/")[0].strip
        j << j[2].split("/")[1].blank? ? nil : j[2].split("/")[1].strip
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