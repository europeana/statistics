require 'rake'
class Provider < ActiveRecord::Base
  attr_accessible :provider_type, :provider_id, :name, :requested_at, :request_end, :is_processed, :wiki_name,:text_at_top,:text_at_bottom,:error_message

  def generate_page(name,id,type)
    load File.join(Rails.root, 'lib', 'tasks', 'page_generator.rake')
    Rake::Task["page_generator:add_provider"].invoke(name,id,type)
  end

  def start_page_builder_process
    self.requested_at = Time.now
    self.is_processed = false
    self.request_end = nil
    self.error_message = nil
    self.save!      
    system "bundle exec rake 'page_generator:add_provider[#{self.name},#{self.provider_id},#{self.provider_type},#{self.wiki_name}]' &"
  end

  def self.testing
    # provider_name = args[:name]
    # provider_ids = args[:id].split(" ")
    # provider_name_slug = URI.escape(provider_name)
    # provider_type = args[:provider_type]

    # provider_name = "Netherlands Institute for Sound and Vision"
    # provider_ids = "09209 2021601 2022102 2021610".split(" ")
    provider_name = "The Wellcome Library"
    provider_ids = "9200105".split(" ")
    provider_name_slug = URI.escape(provider_name)
    provider_type = "DR"

    
    #GA Authentication
    ga_client_id = "79004200365-im8ha2tnhhq01j2qr0d4i7dodhctqaua.apps.googleusercontent.com"
    ga_client_secret = "rBi6Aqu1x9o4gBj7ByydxeK7"
    ga_scope = "https://www.googleapis.com/auth/analytics"
    ga_refresh_token = "1/R96LIdJ7mepE1WVdhi9WtPxZI9JTh2FmIzYcrTaGRnQ"
    ga_ids         = "25899454"

    get_access_token =  Nestful.post "https://accounts.google.com/o/oauth2/token?method=POST&grant_type=refresh_token&refresh_token=#{ga_refresh_token}&client_id=#{ga_client_id}&client_secret=#{ga_client_secret}"
    access_token = JSON.parse(get_access_token.to_json)['access_token']    
    
    ##################################################################  
    page_view_aggr = {}
    page_view_data = []
    page_event_aggr = {}
    page_event_data = []
    page_country_aggr = {}
    page_country_data = []
    
        
=begin
      

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
    
    page_view_data_arr2 = [["Quarter", "Q1", "Q2", "Q3", "Q4","Label", "Size"]]
    page_view_data_quarterly.each do |q_key, q_value|
      qx_value = q_key.split("<__>")
      year  = qx_value[0]
      ttype = qx_value[1]
      itmp  = [ttype]
      q_value.each {|qv,vv| itmp << vv}
      itmp  << year.to_i
      page_view_data_arr2 << itmp
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
    if viz_viz.nil?
      viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Grouped Column Chart - Filter")
    else
      Viz::Viz.find(viz_viz.id).update_attributes({chart: "Grouped Column Chart - Filter", data_filz_id: data_filz.id})
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

#=end # comment end

    # For top 25 countries
    ga_dimension  = "ga:month,ga:year,ga:country"
    ga_metrics    = "ga:pageviews"    
    ga_sort       = '-ga:pageviews'
    ga_max_result = 25
    quarter_hash  = {"q1" => ["01-01", "03-31"], "q2" => ["04-01", "06-30"], "q3" => ["07-01","09-30"], "q4" => ["10-01", "12-31"]}
    for l_year in 2010..Date.today.year
      to_quarter = 4
      if l_year == Date.today.year
        to_quarter  = ((((Date.today.at_beginning_of_month - 1).month - 1) / 3) + 1)
      end

      for l_quarter in 1..to_quarter
        qq_s = quarter_hash["q#{l_quarter}"][0]
        qq_e = quarter_hash["q#{l_quarter}"][1]
        ga_start_date = "#{l_year}-#{qq_s}"
        ga_end_date   = "#{l_year}-#{qq_e}"

        counter = 1
        provider_ids.each do |provider_id|
          ga_filters    = "ga:hostname==www.europeana.eu;ga:pagePath=~/record/#{provider_id}"
          tmp_data = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}&sort=#{ga_sort}&max_results=#{ga_max_result}").read)
          tmp_data = JSON.parse(tmp_data.to_json)["rows"]
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
        end # End of provider
      end # End of Quarter
    end # End of Year

    page_country_data_arr = [["quarter", "year", "iso3", "country", "continent", "count"]]
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

    # Now add or update to top 20 countries table      
    file_name = provider_name + " Top 25 Countries"
    data_filz = Data::Filz.where(file_file_name: file_name).first
    if data_filz.nil?
      data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: page_country_data_arr.to_s )
    else
      Data::Filz.find(data_filz.id).update_attributes({content: page_country_data_arr.to_s})
    end

    # Now adding to viz
    viz_viz = Viz::Viz.where(title: file_name).first
    if viz_viz.nil?
      viz_viz = Viz::Viz.create!(title: file_name, data_filz_id: data_filz.id, chart: "Maps")
    else
      Viz::Viz.find(viz_viz.id).update_attributes({chart: "Maps", data_filz_id: data_filz.id})
    end
    params[:top_countries] = data_filz.slug
#end # comment end
=end
    #Get Top Ten Digital Objects

    ga_metrics="ga:pageviews"
    ga_dimension="ga:pagePath,ga:month,ga:year"    
    ga_sort= "-ga:pageviews"
    ga_max_result = 10000
    ga_start_date = "2014-01-01"
    ga_end_date   = (Date.today.at_beginning_of_month - 1).strftime("%Y-%m-%d")
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
      ga_filters    = "ga:hostname==www.europeana.eu;ga:pagePath=~/record/#{provider_id}"
      g = JSON.parse(open("https://www.googleapis.com/analytics/v3/data/ga?access_token=#{access_token}&start-date=#{ga_start_date}&end-date=#{ga_end_date}&ids=ga:#{ga_ids}&metrics=#{ga_metrics}&dimensions=#{ga_dimension}&filters=#{ga_filters}&sort=#{ga_sort}&max-results=#{ga_max_result}").read)
      data = g['rows']
      
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
        top_ten_digital_objects << [title, img_url, size, title_url, year, quarter]
      end
    end    
    sssssssssssssssss


    file_name = provider_name + " Top 10 Digital Objects"
    data_filz = Data::Filz.where(file_file_name: file_name).first
    if data_filz.nil?
      data_filz = Data::Filz.create!(genre: "API", file_file_name: file_name, content: top_ten_digital_objects.to_s )
    else
      Data::Filz.find(data_filz.id).update_attributes({content: top_ten_digital_objects.to_s})
    end
    

    # params[:top_ten_digital_objects] = data_filz.slug
    # params[:wiki_name] = args[:wiki_name]
  end

  def self.testcsv
    data = CSV.read("test.csv")
    hash_data = []
    head = data.shift
    headers = []
    head.each {|d| headers << d.split(":")[0]}

    data.each do |d|
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
    uniq_data
    # puts uniq_data.to_json    
    # ssss
    

  end

end
