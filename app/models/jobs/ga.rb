class Jobs::Ga < Struct.new(:uid, :lhk, :refresh)
  
  #http://ga-dev-tools.appspot.com/explorer/
  #https://developers.google.com/analytics/devguides/reporting/core/dimsmets
  #https://github.com/chrisle/gattica
  def perform
    begin
      ak = Core::Oauth.first

      #start_date = "2013-06-14"
      #end_date = "2013-07-14"
      ak.reauthenticate?
      
      #access_token = ak.token
      #profile_id = ak.entity_name

      a_json = GRuby::Analytics.get_with_delta(ak.app_password, start_date, end_date, ak.entity_name, "ga:visitors,ga:newVisits,ga:percentNewVisits,ga:visits,ga:bounces,ga:visitBounceRate,ga:timeOnSite,ga:avgTimeOnSite,ga:pageviewsPerVisit,ga:pageviews", nil, nil, nil, refresh)

      puts "check 3"

      if a_json.blank?
        ak.update_attributes(:is_pending => "dead1", last_processed: Time.now)
      else
        a_json.each do |a|
          Ga::GaData.timeless_tag2(ak, a[:tag], a[:val], nil, nil, nil, a[:delta], a[:delta_explaination])
        end
        #=========================================
        puts "check 4"
        ak.update_attributes(:is_pending => "phase1_done", last_processed: Time.now)

        #=========================================

        puts "check 5"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:socialNetwork", "-ga:visits", 11, refresh)
        puts "check 6"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:isMobile", "-ga:visits", 11, refresh)
        puts "check 7"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:region", "-ga:visits", 11, refresh)
        puts "check 8"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:city", "-ga:visits", 11, refresh)
        puts "check 9"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:language", "-ga:visits", 11, refresh)
        puts "check 10"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:browser", "-ga:visits", 11, refresh)
        puts "check 11"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:operatingSystem", "-ga:visits", 11, refresh)
        puts "check 12"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:pageDepth", "-ga:visits", 11, refresh)
        puts "check 13"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:pageviews", "ga:pagePath", "-ga:pageviews", 11, refresh, "famousContent")
        puts "check 14"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:pageviews", "ga:pagePath", "-ga:pageviews", nil, refresh, "customPagesToTrack")

        puts "check 15"
        ak.reauthenticate_google?
        a_json = GRuby::Analytics.get(ak.app_password, start_date, end_date, ak.entity_name, "ga:visits", "ga:month,ga:year", "-ga:visits", 11)
        if !a_json.blank?
          a_json.each do |i|
            Ga::GaData.timeless_tag2(ak, i[0] + "-01-" + i[1], i[2], "trend", nil, nil, nil, nil)
          end
        end

        puts "check 16"
        ak.reauthenticate_google?
        a_json = GRuby::Analytics.get(ak.app_password, start_date, end_date, ak.entity_name, "ga:visits", "ga:hour", "-ga:visits", nil)
        if !a_json.blank?
          a_json.each do |i|
            Ga::GaData.timeless_tag2(ak, i[0], i[1], "hourly-trend", nil, nil, nil, nil)
          end
        end

        puts "check 17"
        ak.reauthenticate_google?
        a_json = GRuby::Analytics.get(ak.app_password, start_date, end_date, ak.entity_name, "ga:visits", "ga:dayOfWeek", "-ga:visits", nil)
        if !a_json.blank?
          a_json.each do |i|
            Ga::GaData.timeless_tag2(ak, i[0], i[1], "dayOfWeek-trend", nil, nil, nil, nil)
          end
        end

        puts "check 18"
        if !ak.ga_keywords.first.blank?
          ak.reauthenticate_google?
          a_json = GRuby::Analytics.get(ak.app_password, start_date, end_date, ak.entity_name, "ga:visits", "ga:keyword", "-ga:visits", nil)
          a_json.each do |i|
            ak.ga_keywords.each do |gak|
              if !i[0].index(gak.keyword).blank?
                Ga::GaData.timeless_tag2(ak, i[0], i[1], "keyword-to-webpage", nil, gak.id, nil, nil)
              end
            end
          end
        end

        puts "check 19"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:source,ga:medium", "-ga:visits", nil, refresh)

        puts "check 20"
        Ga::GaData.loop2(ak, start_date, end_date, "ga:visits", "ga:keyword,ga:medium", "-ga:visits", nil, refresh)

        puts "check 21"
        if ak.ga_account_id.blank? or ak.ga_webproperty_id.blank? or ak.ga_created_at.blank?
          ak.reauthenticate_google?
          accounts = GRuby::Analytics.accounts(ak.app_password, ak.entity_name)
          if !accounts.blank?
            if !accounts.first.blank?
              ak.update_attributes(ga_account_id: accounts.first[0], ga_webproperty_id: accounts.first[1], ga_created_at: Time.parse(accounts.first[2]).to_date)
            end
          end
        end

        goals_response = GRuby::Analytics.goals(ak.app_password, ak.ga_account_id, ak.ga_webproperty_id, ak.entity_name, start_date, end_date)
        goals_response.each do |v_json|
          Ga::GaData.timeless_tag2(ak, v_json[1], v_json[6], "Goals", v_json[0], nil, nil, nil, v_json[7], v_json[8], v_json[2])
        end

        puts "check 22"
        ak.update_attributes(:is_pending => "done", last_request_user_id: nil, last_processed: Time.now)
      end

      EmailMailer.send_email(user.email, "Google Analytics - #{ak.to_s}").deliver
    rescue Exception => ex
      ak.update_attributes(error_message: ex.message.to_s)
    end
  end
    
end
