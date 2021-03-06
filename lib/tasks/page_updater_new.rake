namespace :page_updater_new do 
  
  desc "Create New Provider"  
  task :add_provider, [:name, :id, :provider_type,:wiki_name] => :environment do |t, args|   
    provider_name = args[:name]
    provider_id = args[:id]
    provider_type = args[:provider_type]
    start_date = Date.today.at_beginning_of_month.prev_month.strftime("%Y-%m-%d")
    end_date   = (Date.today.at_beginning_of_month - 1).strftime("%Y-%m-%d")
    provider_wiki_name = ""
    if args[:wiki_name].present?
      provider_wiki_name = args[:wiki_name]
    end    
    provider = Provider.where(name: provider_name).first

    if provider.nil?
      provider = Provider.create!(name: provider_name, provider_id: provider_id, provider_type: provider_type, requested_at: Time.now, request_end: nil, is_processed: false, wiki_name: provider_wiki_name)
    else
      provider = Provider.find(provider.id)
      provider.requested_at = Time.now
      provider.is_processed = false
      provider.request_end = nil
      provider.wiki_name = provider_wiki_name
      provider.error_message = nil
      provider.save!      
    end
        
    Rake::Task["page_updater_new:ga_queries"].invoke(provider_name, provider_id,provider_type,provider_wiki_name,start_date,end_date)    
    begin                                                
      provider.request_end = Time.now
      provider.is_processed = true
      provider.error_message = nil
      provider.save!      
    rescue Exception => e
      puts "==============================="
      puts "oppssss something went wrong"
      puts e.to_s
      puts "==============================="
      provider.error_message = e.to_s
      provider.request_end = Time.now
      provider.is_processed = nil
      provider.save!            
    end

  end

  desc "Fetch Data From GA"
  task :ga_queries, [:name, :id, :provider_type,:wiki_name,:start_date,:end_date]  do |t, args|
    provider_name = args[:name]
    provider_id = args[:id]    
    provider_type = args[:provider_type]
    Rake::Task['page_updater_new:ga_traffic'].invoke(provider_name, provider_id, provider_type,args[:wiki_name],args[:start_date],args[:end_date])
  end

  desc "Fetch Data From GA Only Traffic"
  task :ga_traffic, [:name, :id, :provider_type,:wiki_name,:start_date,:end_date]  do |t, args|
    provider_name = args[:name]
    provider_ids = args[:id].split(" ")
    provider_name_slug = URI.escape(provider_name)
    provider_type = args[:provider_type]

    #GA Authentication
    ga_client_id = "79004200365-im8ha2tnhhq01j2qr0d4i7dodhctqaua.apps.googleusercontent.com"
    ga_client_secret = "rBi6Aqu1x9o4gBj7ByydxeK7"
    ga_scope = "https://www.googleapis.com/auth/analytics"
    ga_refresh_token = "1/R96LIdJ7mepE1WVdhi9WtPxZI9JTh2FmIzYcrTaGRnQ"
    get_access_token =  Nestful.post "https://accounts.google.com/o/oauth2/token?method=POST&grant_type=refresh_token&refresh_token=#{ga_refresh_token}&client_id=#{ga_client_id}&client_secret=#{ga_client_secret}"
    access_token = JSON.parse(get_access_token.to_json)['access_token']    
    
    ##################################################################  
    page_view_aggr = {}
    page_view_data = []
    page_event_aggr = {}
    page_event_data = []
    page_country_aggr = {}
    page_country_data = []
     
    # #, max_results: 999999999
    ga_ids         = "25899454"
    ga_start_date     = args[:start_date]
    ga_end_date       = args[:end_date]
    ga_dimension   = "ga:month,ga:year"
    ga_metrics     = "ga:pageviews"
    provider_ids.each do |provider_id|
      ga_filters     = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider_id}/"        
      tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}").read)      
      next if tmp_data["totalsForAllResults"]["ga:pageviews"].to_i <= 0
      tmp_data = JSON.parse(tmp_data.to_json)["rows"]
      tmp_data.each do |d|
        #custom_regex = "#{provider_id}"
        #custom_regex += "<__>#{d[0]}"
        custom_regex = "#{d[0]}<__>#{d[1]}"
        if d[2].to_i > 0
          if !page_view_aggr[custom_regex]
            page_view_aggr[custom_regex] = d[2].to_i
          else  
            page_view_aggr[custom_regex] = page_view_aggr[custom_regex] + d[2].to_i
          end      
        end
      end
    end
    
    ##################################################################  
    #           For events                                           #
    ##################################################################  
    ga_dimension  = "ga:month,ga:year"
    ga_metrics    = "ga:totalEvents"
    provider_ids.each do |provider_id|
      ga_filters    = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider_id}/;ga:eventCategory=~Redirect"
      tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}").read)
      next if tmp_data["totalsForAllResults"]["ga:totalEvents"].to_i <= 0      
      tmp_data = JSON.parse(tmp_data.to_json)["rows"]
      tmp_data.each do |d|
        #custom_regex = "#{provider_id}"
        #custom_regex += "<__>#{d[0]}"
        custom_regex = "#{d[0]}<__>#{d[1]}"
        if d[2].to_i > 0
          if !page_event_aggr[custom_regex]
            page_event_aggr[custom_regex] = d[2].to_i
          else  
            page_event_aggr[custom_regex] = page_event_aggr[custom_regex] + d[2].to_i
          end
        end
      end
    end
    
    page_view_aggr.each do |px, y|
      final_value = {}
      x = px.split("<__>")
      final_value['pageviews'] = y
      #final_value['provider_id'] = x[0]
      final_value['month'] = x[0]
      final_value['year'] = x[1]
      if page_event_aggr[px]
        final_value['events'] = page_event_aggr[px]
      end
      page_view_data << final_value
    end
    
    # problem while merging data
    page_view_data_quarterly = {}
    page_view_data.each do |data|
      month = data["month"].to_i
      quarter = "Q1"
      quarter = "Q2" if month.between?(4,6)
      quarter = "Q3" if month.between?(7,9)
      quarter = "Q4" if month.between?(10,12)

      if data['pageviews'].to_i > 0 || data['events'].to_i > 0
        quarter1 = "#{data['year']}<__>Pageviews"
        quarter2 = "#{data['year']}<__>CTR"

       if !page_view_data_quarterly[quarter1]
          page_view_data_quarterly[quarter1] = {"Q1" => 0, "Q2" => 0, "Q3" => 0, "Q4" => 0}
          page_view_data_quarterly[quarter1][quarter] =  data['pageviews'].to_i             
       else
          page_view_data_quarterly[quarter1][quarter] = page_view_data_quarterly[quarter1][quarter] + data['pageviews'].to_i
       end

       if !page_view_data_quarterly[quarter2]
          page_view_data_quarterly[quarter2] = {"Q1" => 0, "Q2" => 0, "Q3" => 0, "Q4" => 0}
          page_view_data_quarterly[quarter2][quarter] = data['events'].to_i            
       else
          page_view_data_quarterly[quarter2][quarter] = page_view_data_quarterly[quarter2][quarter] + data['events'].to_i
       end       
      end
    end    

    if page_view_data_quarterly.count > 0    
      file_name = provider_name + " Traffic"
      data_filz = Data::Filz.where(file_file_name: file_name).first
      old_content  = JSON.parse(data_filz.content)
      old_content_to_push = [old_content.shift]
      old_content_to_change = []   
      old_content.each do |k|
        if k[5] != Date.parse(ga_start_date).year
          old_content_to_push << k
          next
        else          
          old_content_to_change << k            
        end        
      end
      pg_view = page_view_data_quarterly.shift[1]
      ctr_view = page_view_data_quarterly.shift[1]
      for pi in 1..4
        old_content_to_change[0][pi] = old_content_to_change[0][pi].to_i + pg_view["Q#{pi}"].to_i
        old_content_to_change[1][pi] = old_content_to_change[1][pi].to_i + ctr_view["Q#{pi}"].to_i
      end
      old_content_to_change.each {|k| old_content_to_push << k}
      data_filz.update_attributes({content: old_content_to_push.to_s})
    end
    #Get Media type    
    api_provider_type = "DATA_PROVIDER"
    if provider_type == "PR"
      api_provider_type = "PROVIDER" 
    end

    e_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{api_provider_type}%3a%22#{provider_name_slug}%22&facet=TYPE&profile=facets&rows=0"
    if provider_name_slug.include?("&")
      e_url = URI.encode("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{api_provider_type}%3a%22#{provider_name_slug}%22&facet=TYPE&profile=facets&rows=0")  
    end

    media_type =  open(e_url).read
    if media_type["facets"].present?
      all_types = JSON.parse(media_type)["facets"][0]["fields"]
      media_type_data = {}
      all_types.each do |type|
        media_type_data[type["label"]] = type["count"].to_i
      end
      
      values_data = media_type_data.to_a
      values_data.unshift(['Type', 'Size'])
      media_type_data_formatted =  values_data
      
      # Now add or update to Media type table      
      file_name = provider_name + " Media Type"
      data_filz = Data::Filz.where(file_file_name: file_name).first      
      if data_filz.nil?
        data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: media_type_data_formatted.to_json )
      else
        Data::Filz.find(data_filz.id).update_attributes({content: media_type_data_formatted.to_json})
      end

      #adding to viz
      viz_viz = Viz::Viz.where(title: file_name).first      
      if viz_viz.nil?
        viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Column Chart", mapped_output: media_type_data_formatted.to_json )
      else
        Viz::Viz.find(viz_viz.id).update_attributes({chart: "Column Chart", mapped_output: media_type_data_formatted.to_json, data_filz_id: data_filz.id })
      end 
    end

    #Get Reusable
    e_url = "http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{api_provider_type}%3a%22#{provider_name_slug}%22&facet=REUSABILITY&profile=facets&rows=0"
    if provider_name_slug.include?("&")
      e_url = URI.encode("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{api_provider_type}%3a%22#{provider_name_slug}%22&facet=REUSABILITY&profile=facets&rows=0")  
    end
    reusable = open(e_url).read
    if reusable["facets"].present?
      all_types = JSON.parse(reusable)["facets"][0]["fields"]
      reusable_data = {}
      all_types.each do |type|        
        reusable_data[type["label"]] = type["count"].to_i if type["count"].to_i > 0
      end
      
      values_data = reusable_data.to_a
      values_data.unshift(['Type', 'Size'])
      reusable_data_formatted =  values_data

      # Now add or update to Reusable type table      
      file_name = provider_name + " Reusable"
      data_filz = Data::Filz.where(file_file_name: file_name).first
      if data_filz.nil?
        data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: reusable_data_formatted.to_s )
      else
        Data::Filz.find(data_filz.id).update_attributes({content: reusable_data_formatted.to_s})
      end

      viz_viz = Viz::Viz.where(title: file_name).first      
      if viz_viz.nil?
        viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Pie Chart", mapped_output: reusable_data_formatted.to_json )
      else
        Viz::Viz.find(viz_viz.id).update_attributes({chart: "Pie Chart", mapped_output: reusable_data_formatted.to_json, data_filz_id: data_filz.id })
      end

    end
    
    # For top 25 countries
    ga_dimension  = "ga:month,ga:year,ga:country"
    ga_metrics    = "ga:pageviews"    
    ga_sort       = '-ga:pageviews'
    ga_max_result = 25
    quarter_hash  = {"q1" => ["01-01", "03-31"], "q2" => ["04-01", "06-30"], "q3" => ["07-01","09-30"], "q4" => ["10-01", "12-31"]}
    l_year = Date.parse(ga_start_date).year
    l_quarter  = ((((Date.parse(ga_start_date)).month - 1) / 3) + 1)
    qq_s = quarter_hash["q#{l_quarter}"][0]
    qq_e = quarter_hash["q#{l_quarter}"][1]
    ga_start_date = "#{l_year}-#{qq_s}"
      counter = 1
      provider_ids.each do |provider_id|
        ga_filters    = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider_id}/"
        tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}&sort=#{ga_sort}&max_results=#{ga_max_result}").read)
        tmp_data = tmp_data["rows"]
        next if tmp_data.nil?          
        page_country_aggr = {}
        tmp_data.each do |d|
          #custom_regex = "#{provider_id}"
          custom_regex = "q#{l_quarter}<__>#{d[1]}<__>#{d[2]}"
          if !page_country_aggr[custom_regex]
            page_country_aggr[custom_regex] = d[3].to_i
            counter += 1
          else  
            page_country_aggr[custom_regex] = page_country_aggr[custom_regex] + d[3].to_i
          end                  
          break if counter > 25
        end # End of GA          
        page_country_aggr.each do |px, y|
          final_value = {}
          x = px.split("<__>")
          final_value['count'] = y            
          final_value['quarter'] = x[0]
          final_value['year'] = x[1].to_i
          final_value['country'] = x[2]
          page_country_data << final_value
        end
      end #End of Provider
       
      if page_country_data.count > 0
        #page_country_data_arr = [["quarter", "year", "iso3", "country", "continent", "count"]]
        page_country_data_arr = []
        page_country_data.each do |kvalue|
          country = kvalue['country']
          iso_code = IsoCode.where(country: country).first
          if !iso_code.nil?        
            code = iso_code.code
            continent = iso_code.continent
          else
            code = ""
            continent = ""
          end      
          page_country_data_arr << [kvalue['quarter'], kvalue['year'].to_i, code, country, continent, kvalue['count']]
        end

        file_name = provider_name + " Top 25 Countries"
        data_filz = Data::Filz.where(file_file_name: file_name).first
        old_content = JSON.parse(data_filz.content)
        old_content_to_push = [old_content.shift]
        old_content.each do |k|
          old_content_to_push << k  unless k[0] == "q#{l_quarter}" and k[1].to_i == l_year
        end
        page_country_data_arr.each {|k| old_content_to_push << k} 
        data_filz.update_attributes({content: old_content_to_push.to_s})
      end
    #Get Top Ten Digital Objects
    ga_metrics="ga:pageviews"
    ga_dimension="ga:pagePath,ga:month,ga:year"    
    ga_sort= "-ga:pageviews"
    ga_max_result = 10000
    header_data = ["title","image_url","size","title_url","year","quarter"]
    europeana_url = "http://europeana.eu/api/v2/"
    top_ten_digital_objects = []
    top_ten_digital_objects << header_data
    base_title_url = "http://www.europeana.eu/portal/record/"
    uniq_objects = {}
    provider_arr = {}
    skip_value = {}
    ten_records_arr = {}
    min_year = Date.today.year
    provider_ids.each do |provider_id|
      ga_filters    = "ga:hostname=~europeana.eu;ga:pagePath=~/#{provider_id}/"      

      begin
        g = JSON.parse(open(URI.encode("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}&sort=#{ga_sort}&max-results=#{ga_max_result}")).read)
      rescue Exception => e
        get_access_token =  Nestful.post "https://accounts.google.com/o/oauth2/token?method=POST&grant_type=refresh_token&refresh_token=#{ga_refresh_token}&client_id=#{ga_client_id}&client_secret=#{ga_client_secret}"
        access_token = JSON.parse(get_access_token.to_json)['access_token']    
        g = JSON.parse(open(URI.encode("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}&sort=#{ga_sort}&max-results=#{ga_max_result}")).read)        
      end

      data = g['rows']
      
      next if data.nil?
      total_records = data.count
      qx_counter = 0
      data.each do |data_element|
        qx_counter += 1
        puts "#{total_records} of #{qx_counter} ...."
        views   = data_element[3].to_i
        year    = data_element[2].to_i
        month   = data_element[1].to_i
        if min_year > year
          min_year = year
        end
        pg_path = data_element[0]
        quarter = "q1"
        quarter = "q2" if month.between?(4,6)
        quarter = "q3" if month.between?(7,9)
        quarter = "q4" if month.between?(10,12)
        
        skip_val = "#{quarter}<__>#{year}<__>#{provider_id}"
        skip_value[skip_val] = 0 if !skip_value[skip_val]

        if skip_value[skip_val] < 10
          puts skip_value
          puts "============================="          
          b = pg_path.split("/") 
          begin
            record_provider_id = "#{b[2]}/#{b[3]}/#{b[4].split(".")[0]}"
            a = 1  
          rescue Exception => e
            a = 0
          end
          next if a == 0
          
          euro_api_url = "#{europeana_url}#{record_provider_id}.json?wskey=api2demo&profile=full"
          begin
            g = JSON.parse(open(euro_api_url).read)  
            a = 1
          rescue Exception => e
            a = 0
          end
          next if a == 0
          
          if g["success"]
            if g["object"]["proxies"][0]['dcTitle']
            end
            if g["object"]["title"]
              title = g["object"]["title"][0] 
            elsif g["object"]['proxies'][0]['dcTitle']
              g["object"]["proxies"][0]['dcTitle'].each do |x,c|
                title = c[0]
              end
            else
              title = "No Title Found"
            end
            img_url_path = g["object"]['europeanaAggregation']['edmPreview']
            if img_url_path.nil?
              img_url_path = "http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO"
            end            
            p_path = "#{base_title_url}#{g["object"]['europeanaAggregation']['about'].split("/")[3]}/#{g["object"]['europeanaAggregation']['about'].split("/")[4]}.html"
            obj_key = "#{quarter}<__>#{year}<__>#{title}<__>#{provider_id}"
            if !ten_records_arr[obj_key]
              ten_records_arr[obj_key] = {"title" => title, "img_url_path" => img_url_path, "views" => views, "page_path" => p_path, "quarter" => quarter, "year" =>  year, "counter" => 1, "provider_id" => provider_id}
              skip_value[skip_val] = skip_value[skip_val] + 1
            else
              ctr = ten_records_arr[obj_key]["counter"]
              if ctr < 10
                ten_records_arr[obj_key]["views"] = ten_records_arr[obj_key]["views"] + views
              end            
            end          
          end
        end        
      end
      
      ten_records_arr.each do |key, value|
        values  = key.split("<__>")
        quarter = values[0]
        year    = values[1]
        title   = value["title"] || ""
        img_url = value["img_url_path"] || ""
        size    = value["views"] || 0
        title_url = value["page_path"] || ""
        title   = title.gsub(","," ")
        top_ten_digital_objects << [title, img_url, size, title_url, year, quarter]
      end
    end

    hash_data = []
    headers = top_ten_digital_objects.shift
    top_ten_digital_objects.each do |d|
      tmp_arr = {}
      headers.each_with_index do |h,i|
        tmp_arr[h] = d[i]
      end
      hash_data << tmp_arr
    end

    uniq_data = {}
    hash_data.each do |h|
      title   = h["title"]
      year    = h["year"]
      quarter = h["quarter"]
      size    = h["size"].to_i

      key = "#{year}<__>#{quarter}"
      uniq_data[key] = {"count" => 1} if !uniq_data[key]
      count = uniq_data[key]["count"]      
      
      next if count >= 10      
      if !uniq_data[key][title]
        uniq_data[key][title]   = {"data" => h, "size" => size}
      else        
        uniq_data[key]["count"] = count + 1
        uniq_data[key][title]["size"]  = uniq_data[key][title]["size"] + size      
      end
    end
    
    format_data = [["title", "image_url", "size", "title_url", "year", "quarter"]]
    count = 0
    uniq_data.each do |k,u|
      keys = u.keys
      keys.shift
      keys.each do |key|
        d_data = u[key]["data"]
        title = d_data["title"]
        image_url = d_data["image_url"]
        size =  d_data["size"].to_i
        title_url = d_data["title_url"]
        year = d_data["year"].to_i
        quarter = d_data["quarter"] 
        format_data << [title, image_url, size, title_url, year, quarter]      
      end
    end
    top_ten_digital_objects = format_data
    if top_ten_digital_objects.count > 1 
      top_ten_digital_objects.shift
      file_name = provider_name + " Top 10 Digital Objects"
      data_filz = Data::Filz.where(file_file_name: file_name).first
      old_content = JSON.parse(data_filz.content)
      old_content_to_push = [old_content.shift]
      old_content.each do |k|
        old_content_to_push << k  unless k[5] == "q#{l_quarter}" and k[4].to_i == l_year
      end
      top_ten_digital_objects.sort_by{|k| -k[2]}
      top_ten_digital_objects.each{|k| old_content_to_push << k}
      data_filz.update_attributes({content:old_content_to_push.to_s})
    end
    params = {name: provider_name}
    #adding to Article
    if args[:wiki_name] and (!args[:wiki_name].nil? or !args[:wiki_name].blank?)
      params[:wiki_name] = args[:wiki_name]
      Rake::Task['page_updater_new:article'].invoke(params)
    end

  end

  desc "Add Data To Article"
  task :article, :params  do |t, args|        
    params    = args[:params]
    name      = params[:name]
    article = Cms::Article.where(title: name).first
    wiki_name = params[:wiki_name]
    html_template = ""
    if 1 == 1 #article.nil?
      #Collection    
      unless wiki_name.blank?
        wiki_url =  URI.encode("http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=#{wiki_name}")
        wiki_json = JSON.parse(open(wiki_url).read)
        wiki_context = wiki_json["query"]["pages"].values.shift["extract"]
        html_template = ""
        if wiki_context.length > 0
          length = wiki_context.length > 300? 300 : wiki_context.length
          wiki_context = wiki_context[0..length].gsub("\n","").gsub("<p></p>","").gsub("</p>","")
          html_template += "<div class='row'><div class='col-sm-12'><div id='wiki_name'>#{wiki_context}...<a href='http://en.wikipedia.org/wiki/#{wiki_name}' target='blank '><b>Read more on Wikipedia</b></a></p></div></div></div>"
        end
      end      
      article = Cms::Article.where(title: name).first
      if article.nil?
        Cms::Article.create!(title: name, is_published: true, description: html_template.to_s.html_safe, position: 0,is_autogenerated: true)
      else
        Cms::Article.find(article.id).update_attributes({title: name, is_published: true, description: html_template.to_s.html_safe, position: 0,is_autogenerated: true})
      end
    end
  end
end
