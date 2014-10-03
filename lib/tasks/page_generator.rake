  namespace :page_generator do 
  
  desc "Create New Provider"  
  task :add_provider, [:name, :id, :provider_type,:wiki_name] => :environment do |t, args|   
    provider_name = args[:name]
    provider_id = args[:id]
    provider_type = args[:provider_type]
    provider = Provider.where(name: provider_name).first

    if provider.nil?
      provider = Provider.create!(name: provider_name, provider_id: provider_id, provider_type: provider_type, requested_at: Time.now, request_end: nil, is_processed: false)
    else
      provider = Provider.find(provider.id)
      provider.requested_at = Time.now
      provider.is_processed = false
      provider.request_end = nil
      provider.save!      
    end

    begin
      Rake::Task["page_generator:ga_queries"].invoke(provider_name, provider_id,provider_type,args[:wiki_name])
      provider.request_end = Time.now
      provider.is_processed = true
      provider.error_message = nil
      provider.save!      
    rescue Exception => e
      provider.error_message = e.to_s
      provider.request_end = Time.now
      provider.is_processed = false
      provider.save!            
    end


  end

  desc "Fetch Data From GA"
  task :ga_queries, [:name, :id, :provider_type,:wiki_name]  do |t, args|
    provider_name = args[:name]
    provider_id = args[:id]    
    provider_type = args[:provider_type]
    Rake::Task['page_generator:ga_traffic'].invoke(provider_name, provider_id, provider_type,args[:wiki_name])
  end

  desc "Fetch Data From GA Only Traffic"
  task :ga_traffic, [:name, :id, :provider_type,:wiki_name]  do |t, args|
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
     
    #, max_results: 999999999
    ga_start_date  = '2005-01-01'
    ga_end_date    = Date.today.strftime("%Y-%m-%d")
    ga_ids         = "25899454"
    ga_dimension   = "ga:month,ga:year"
    ga_metrics     = "ga:pageviews"

    provider_ids.each do |provider_id|
      ga_filters     = "ga:hostname==www.europeana.eu;ga:pagePath=~/record/#{provider_id}"        
      tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}").read)
      tmp_data = JSON.parse(tmp_data.to_json)["rows"]
      tmp_data.each do |d|
        #custom_regex = "#{provider_id}"
        #custom_regex += "<__>#{d[0]}"
        custom_regex = "#{d[0]}<__>#{d[1]}"
        if !page_view_aggr[custom_regex]
          page_view_aggr[custom_regex] = d[2].to_i
        else  
          page_view_aggr[custom_regex] = page_view_aggr[custom_regex] + d[2].to_i
        end      
      end
    end

    ##################################################################  
    #           For events                                           #
    ##################################################################  
    ga_dimension  = "ga:month,ga:year"
    ga_metrics    = "ga:totalEvents"

    provider_ids.each do |provider_id|
      ga_filters    = "ga:hostname==www.europeana.eu;ga:pagePath=~/record/#{provider_id};ga:eventCategory=~Redirect"
      tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}").read)
      tmp_data = JSON.parse(tmp_data.to_json)["rows"]
      tmp_data.each do |d|
        #custom_regex = "#{provider_id}"
        #custom_regex += "<__>#{d[0]}"
        custom_regex = "#{d[0]}<__>#{d[1]}"
        if !page_event_aggr[custom_regex]
          page_event_aggr[custom_regex] = d[2].to_i
        else  
          page_event_aggr[custom_regex] = page_event_aggr[custom_regex] + d[2].to_i
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

    page_view_data_arr = [["month", "year", "pageviews", "events"]]
    page_view_data.each do |kvalue|
      page_view_data_arr << [kvalue['month'], kvalue['year'].to_i, kvalue['pageviews'], kvalue['events']]
    end

    page_view_data_quarterly = {}
    page_view_data.each do |data|
       quarter = "Q1"
       if data['month'].to_i > 3 and data['month'].to_i < 7
        quarter = "Q2"
       elsif data['month'].to_i > 6 and data['month'].to_i < 10
         quarter = "Q3"           
       elsif data['month'].to_i > 9 and data['month'].to_i < 13
         quarter = "Q4"           
       end

       quarter = "#{data['year']}<__>#{quarter}"

       if !page_view_data_quarterly[quarter]
          page_view_data_quarterly[quarter] = {pageviews: data['pageviews'].to_i, events: data['events'].to_i, year: data["year"] }
       else
          page_view_data_quarterly[quarter][:pageviews] = page_view_data_quarterly[quarter][:pageviews] + data['pageviews'].to_i
          page_view_data_quarterly[quarter][:events] = page_view_data_quarterly[quarter][:events] + data['events'].to_i
       end

    end
    page_view_data_arr2 = []
    page_view_data_arr2 = [["Quarter", "Size", "Label", "Year"]]
    page_view_data_quarterly.each do |q_key, q_value|
      quarter_value = q_key.split("<__>")[1]
      year = q_key.split("<__>")[0].to_i
      page_view_data_arr2 << [quarter_value, q_value[:pageviews], "Pageviews", year]
      page_view_data_arr2 << [quarter_value, q_value[:events], "CTR", year]
    end
    # Adding to data_filz           
    file_name = provider_name + " Traffic"
    data_filz = Data::Filz.where(file_file_name: file_name).first
    if data_filz.nil?
      data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: page_view_data_arr2 )
    else
      Data::Filz.find(data_filz.id).update_attributes({content: page_view_data_arr2})
    end

    #adding to viz
    viz_viz = Viz::Viz.where(title: file_name).first    
    viz_map = {:"Quarter" => "X", :"Size" => "Y", :"Label" => "Group"}.to_json
    if viz_viz.nil?
      viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Grouped Column Chart", map: viz_map, mapped_output: page_view_data_arr2.to_json )
    else
      Viz::Viz.find(viz_viz.id).update_attributes({chart: "Grouped Column Chart", map: viz_map, mapped_output: page_view_data_arr2.to_json })
    end

    #params = {name: provider_name, pageviews: data_filz.slug, id: provider_id }
    params = {name: provider_name, pageviews: data_filz.slug}

    #Get Media type    
    api_provider_type = "DATA_PROVIDER"
    if provider_type == "PR"
      api_provider_type = "PROVIDER"
    end
    media_type = open("http://www.europeana.eu/api/v2/search.json?wskey=api2demo&query=#{api_provider_type}%3a%22#{provider_name_slug}%22&facet=TYPE&profile=facets&rows=0").read
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
        data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: media_type_data_formatted.to_s )
      else
        Data::Filz.find(data_filz.id).update_attributes({content: media_type_data_formatted.to_s})
      end

      #adding to viz
      viz_viz = Viz::Viz.where(title: file_name).first
      viz_map = {:"Type" => "X", :"Size" => "Y"}.to_json
      if viz_viz.nil?
        viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Column Chart", map: viz_map, mapped_output: media_type_data_formatted.to_json )
      else
        Viz::Viz.find(viz_viz.id).update_attributes({chart: "Column Chart", map: viz_map, mapped_output: media_type_data_formatted.to_json })
      end
      params[:media_types] = data_filz.slug
    end

    #Get Reusable        
    reusable = open("http://europeana.eu/api//v2/search.json?wskey=api2demo&query=*%3A*%22#{provider_name_slug}%22&start=1&rows=24&profile=facets&facet=REUSABILITY").read
    if reusable["facets"].present?
      all_types = JSON.parse(reusable)["facets"][0]["fields"]
      reusable_data = {}
      all_types.each do |type|
        reusable_data[type["label"]] = type["count"].to_i
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

      #adding to viz
      viz_viz = Viz::Viz.where(title: file_name).first
      viz_map = {:"Type" => "Dimension", :"Size" => "Size"}.to_json
      if viz_viz.nil?
        viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Pie Chart", map: viz_map, mapped_output: reusable_data_formatted.to_json )
      else
        Viz::Viz.find(viz_viz.id).update_attributes({chart: "Pie Chart", map: viz_map, mapped_output: reusable_data_formatted.to_json })
      end
      params[:reusable] = data_filz.slug
    end

    # For top 25 countries
    ga_start_date = '2005-01-01'
    ga_end_date   = Date.today.strftime("%Y-%m-%d")
    ga_dimension  = "ga:month,ga:year,ga:country"
    ga_metrics    = "ga:pageviews"    
    ga_sort       = '-ga:pageviews'
    ga_max_result = 25


    provider_ids.each do |provider_id|
      ga_filters    = "ga:hostname==www.europeana.eu;ga:pagePath=~/record/#{provider_id}"
      tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}&sort=#{ga_sort}&max_results=#{ga_max_result}").read)
      tmp_data = JSON.parse(tmp_data.to_json)["rows"]

      tmp_data.each do |d|
        #custom_regex = "#{provider_id}"
        custom_regex = "#{d[0]}<__>#{d[1]}<__>#{d[2]}"
        if !page_country_aggr[custom_regex]
          page_country_aggr[custom_regex] = d[3].to_i
        else  
          page_country_aggr[custom_regex] = page_country_aggr[custom_regex] + d[3].to_i
        end      
      end
    end

    page_country_aggr.each do |px, y|
      final_value = {}
      x = px.split("<__>")
      final_value['pageviews'] = y
      #final_value['provider_id'] = x[0]
      final_value['month'] = x[0]
      final_value['year'] = x[1].to_i
      final_value['country'] = x[2]
      if page_country_aggr[px]
        final_value['events'] = page_event_aggr[px]
      end
      page_country_data << final_value
    end

    page_country_data_arr = [["month", "year", "iso2", "country", "size"]]
    page_country_data.each do |kvalue|
      country = kvalue['country']
      iso_code = IsoCode.where(country: country).first
      if !iso_code.nil?        
        iso_code = iso_code.code
      else
        iso_code = ""
      end      
      page_country_data_arr << [kvalue['month'], kvalue['year'].to_i, iso_code, country, kvalue['pageviews']]
    end
    
    # Now add or update to top 20 countries table      
    file_name = provider_name + " Top 25 Countries"
    data_filz = Data::Filz.where(file_file_name: file_name).first
    if data_filz.nil?
      data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: page_country_data_arr.to_s )
    else
      Data::Filz.find(data_filz.id).update_attributes({content: page_country_data_arr.to_s})
    end

    params[:top_countries] = data_filz.slug

    #Get Top Ten Digital Objects
    start_date= "2005-01-01"
    end_date= Date.today.strftime("%Y-%m-%d")
    ga_ids="ga:25899454"
    ga_metrics="ga:pageviews"
    ga_dimensions="ga:pagePath"

    header_data = ["title","image_url","size","title_url"]
    europeana_url = "http://europeana.eu/api/v2/"
    top_ten_digital_objects = []
    top_ten_digital_objects << header_data
    base_title_url = "http://www.europeana.eu/portal/record/"
    provider_ids.each do |provider_id|
      ga_filters="ga:hostname==www.europeana.eu;ga:pagePath=~/record/#{provider_id}"
      ga_sort= "-ga:pageviews"
      base_url = "https://www.googleapis.com/analytics/v3/data/ga?"
      url = base_url+"access_token=#{access_token}"
      url = url + "&start-date=#{start_date}"
      url = url + "&end-date=#{end_date}"
      url = url + "&ids=#{ga_ids}"
      url = url + "&metrics=#{ga_metrics}"
      url = url + "&dimensions=#{ga_dimensions}"
      url = url + "&filters=#{ga_filters}"
      url = url + "&sort=#{ga_sort}"
      g =  open(url).read

      data = JSON.parse(g)['rows']
      count = 0
      data.each do |data_element| 
        tmp_array = []
        if data_element[0] != ""
          b = data_element[0].split("/")
          record_provider_id = "#{b[2]}/#{b[3]}/#{b[4].split(".")[0]}"
          euro_api_url = "#{europeana_url}#{record_provider_id}.json?wskey=api2demo&profile=full"
          g = JSON.parse(open(euro_api_url).read)


          if g["success"]
            if g["object"]["title"]
              title = g["object"]["title"][0] 
            elsif g["object"]['proxies'][0]['dcTitle']["EN"]  
              title = g["object"]['proxies'][0]['dcTitle']["EN"][0]
            elsif g["object"]['proxies'][0]['dcTitle']["def"]
              title = g["object"]['proxies'][0]['dcTitle']["def"][0]
            elsif g["object"]['proxies'][0]['dcTitle']["fr"]
              title = g["object"]['proxies'][0]['dcTitle']["fr"][0]
            elsif g["object"]['proxies'][0]['dcTitle']["de"]
              title = g["object"]['proxies'][0]['dcTitle']["de"][0]
            else
              title = "No Title Found"
            end

            tmp_array << title
            img_url_path = g["object"]['europeanaAggregation']['edmPreview']
            if img_url_path.nil?
              img_url_path = "http://europeanastatic.eu/api/image?size=FULL_DOC&type=VIDEO"
            end
            tmp_array << img_url_path
            tmp_array << data_element[1].to_i
            tmp_array << "#{base_title_url}#{g["object"]['europeanaAggregation']['about'].split("/")[3]}/#{g["object"]['europeanaAggregation']['about'].split("/")[4]}.html"
            count = count + 1;
            top_ten_digital_objects << tmp_array
          end
        end
        break if count >= 50
      end    
    end

    top_ten_digital_objects_title =  top_ten_digital_objects.shift
    top_ten_digital_objects = top_ten_digital_objects.sort_by{|k| -k[2]}
    final_top_ten_digital_objects = []
    final_top_ten_digital_objects2 = {}
    count = 0
    top_ten_digital_objects.each do |k|        
      if count < 10
        if !final_top_ten_digital_objects2[k[3]].present?
          final_top_ten_digital_objects2[k[3]] = k
          count +=1
        else
          final_top_ten_digital_objects2[k[3]][2] = final_top_ten_digital_objects2[k[3]][2].to_i + k[2].to_i
        end        
      else
        break
      end
    end
    final_top_ten_digital_objects2.each do |tkey, tvalue|
      final_top_ten_digital_objects << tvalue  
    end
    final_top_ten_digital_objects = final_top_ten_digital_objects.sort_by{|k| -k[2]}
    final_top_ten_digital_objects.unshift(top_ten_digital_objects_title)

    file_name = provider_name + " Top 10 Digital Objects"
    data_filz = Data::Filz.where(file_file_name: file_name).first
    if data_filz.nil?
      data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: final_top_ten_digital_objects.to_s )
    else
      Data::Filz.find(data_filz.id).update_attributes({content: final_top_ten_digital_objects.to_s})
    end
    params[:top_ten_digital_objects] = data_filz.slug
    params[:wiki_name] = args[:wiki_name]

    #adding to Article    
    Rake::Task['page_generator:article'].invoke(params)

  end

  desc "Add Data To Article"
  task :article, :params  do |t, args|    
    params = args[:params]
    name = params[:name]    
    id = params[:id]    
    page_view_data_name = params[:pageviews]
    page_country_data_name = params[:top_countries]
    article = Cms::Article.where(title: name).first
    wiki_name = params[:wiki_name]
    wiki_url =  URI.encode("http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=#{wiki_name}")
    wiki_json = JSON.parse(open(wiki_url).read)
    wiki_context = ActionView::Base.full_sanitizer.sanitize(wiki_json["query"]["pages"].values.shift["extract"])
    wiki_context = wiki_context[0..300]   
    if 1 == 1 #article.nil?
      #Collection    
      html_template = "<div class='row'><div class='col-sm-12'><div id='wiki_name'><p>#{wiki_context}...<a href='http://en.wikipedia.org/wiki/#{wiki_name}' target='blank'><b>Read more on Wikipedia</b></a><p></div></div></div>"
      html_template  += "<h3>Collection in Europeana</h3><p></p>"
      html_template += "<h2 id='collection-in-europeana-api' provider-id=\"#{name}\"></h2> Digital objects in Europeana <p></p>"

      #media types
      media_type_chart = "<h3>No Chart to Display</h3>"
      if params[:media_types].present?
        media_type_chart = "<div class='pykih-viz' data-slug-id='#{params[:media_types]}' id='#{params[:media_types]}'></div><a href='/articles/#{params[:media_types]}/csv' class='pull-left' >Download CSV</a>"
      end
      html_template += "<div class='row'><div class='col-sm-6'><h4>Media Types</h4>"
      html_template += "This chart displays a breakdown of the composition of the collection that has been made availible via Europeana.eu.<p></p>"
      html_template += "#{media_type_chart}</div>"

      #Reusable
      reusable_chart = "<h3>No Chart to Display</h3>"
      if params[:reusable].present?
        reusable_chart = "<div class='pykih-viz' data-slug-id='#{params[:reusable]}' id='#{params[:reusable]}'></div><a href='/articles/#{params[:reusable]}/csv' class='pull-right' >Download CSV</a>"
      end
      html_template += "<div class='col-sm-6'><h4>Reusable</h4>"
      html_template += "This chart displays what percentage of the collection is reusable based on the licenses that have been assigned to the digital objects in the collection. <p></p>"
      html_template += "#{reusable_chart}</div>"

      #View on Europeana
      page_view_chart = "<div data-slug-id='#{page_view_data_name}' id='page_view_click_chart' chart='custom-column-group-chart'></div><a href='/articles/#{page_view_data_name}/csv' class='pull-right' >Download CSV</a>"
      html_template += "<h2>Views on Europeana</h2><p></p>"
      # html_template += "<div class='row'><div class='col-sm-12'><div id='menu'></div></div></div><p></p>"
      html_template += "For the selected time period the data and charts in the category are based on the number of views of the Wellcome Library collection on Europeana.eu. The number of views for a collection are dependant on a number of factors such as the size of the collection, the quality of the meta-data that accompanies each digital object and the re-usability of the collection."
      html_template += "<div class='row'><div class='col-sm-12'><h4>Views & Click-Throughs</h4>"
      html_template += "This charts displays the total views of the collection on Europeana.eu and the number of times a user clicked through to the providers website. Repeated views and click-throughs of the same digital objects are counted."
      html_template += "#{page_view_chart}</div></div>"    

      #Countries
      page_country_chart = "<div chart='custom-country-map' data-slug-id='#{page_country_data_name}' id='page_view_country_chart'></div>"
      html_template += "<div class='row'><div class='col-sm-12'><h4>Top 25 Countries</h4>"
      html_template += "This chart displays the top 25 countries that generated the most views for this collection on Europeana.eu."
      html_template += "#{page_country_chart}</div><a href='/articles/#{page_country_data_name}/csv' class='pull-right'>Download CSV</a></div>"

      #Digital Objects
      html_template += "<h4>Top 10 Digital Objects</h4>"
      html_template += "This chart displays the top 10 digital objects from the collection that generated the most views on Europeana.eu."
      html_template += "<div class='row'><div class='col-sm-12'><div id='top-viewed-items-europena' data-src='#{params[:top_ten_digital_objects]}'></div></div><a href='/articles/#{params[:top_ten_digital_objects]}/csv' class='pull-right'>Download CSV</a><div>"

      #Reach - Wikipedia
      # html_template += "<h2>Reach on Wikipedia</h2><P></P>"
      # html_template += "This charts displays the total views of the collection on Europeana.eu and the number of times a user clicked through to the providers website. Repeated views and click-throughs of the same digital objects are counted."
      # html_template += "<h4>Impressions</h4>"    

      #Impression
      # html_template += "<div class='row'><div class='col-sm-12'>"
      # html_template += "<h1>Faf du plessis</h1> </div></div>"

      #Uploaded Images
      # html_template += "<div class='row'><div class='col-sm-6'><h4>Uploaded Images</h4>"
      # html_template += "<h1>David Miller</h1> </div>"

      #Used Images
      # html_template += "<div class='col-sm-6'><h4>Used Images</h4>"
      # html_template += "<h1>JP Dumminy</h1> </div></div>"

      article = Cms::Article.where(title: name).first
      if article.nil?
        Cms::Article.create!(title: name, is_published: true, description: html_template.to_s.html_safe, position: 0)
      else
        Cms::Article.find(article.id).update_attributes({title: name, is_published: true, description: html_template.to_s.html_safe, position: 0})
      end

    end
  end
end


# Call Wikipedia Api for description and store it  in variable
#   url = URI.encode("http://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=#{provider_wiki_name}")
#   a = JSON.parse(open(url).read)
#   context = a["query"]["pages"].values.shift["extract"]