class RawController < ApplicationController
  
  def index
    render layout: "raw"    
  end
  
  def upload    
    
    string_data = ""
    file_name = params[:file_name].tempfile    
    file_name.each do |file_data|
      string_data += file_data      
    end

    valid_data = validate_rows(string_data)
    # error_count = 0
    # csv_data = CSV::parse(string_data)
    # csv_head = csv_data[0].length
    # part_data = ""
    #       data = spreadsheet.row(i)

    # (1..csv_head).each do |i|
    #   part_data = csv_data.row[i]
    # end

    #render text: valid_data
    #valid_csv = validate_rows(file_name)
    
    

    
#     require_dependency 'data/file'
#     #Saving to database
# #    file_which_saved = string_data
#     new_data = Data::File.new(params)
#     # new_data.title = "test"
#     # new_data.data  = file_which_saved
#     new_data.save!
#     render text: params.to_json

    # render text: string_data
    
    if !params[:file].blank?
      title = params[:title]["title"]  
      name = params[:file].original_filename

      #After file upload
      config_data = JSON.parse(File.read("public/raw-lib/config.json"))
      

      File.open("public/raw-lib/config.json", 'w+') do |f|
        config_data["samples"] << { "url"=>"/raw-lib/samples/#{name}",
                                  "title"=>"#{title}"}        
        f.write(config_data.to_json)            
      end

      #Saving to database
      file_which_saved = File.read("public/raw-lib/samples/#{name}")
      new_data = Rawdata.new
      new_data.title = title
      new_data.data  = file_which_saved
      new_data.save!

      redirect_to raw_index_path
    end

  end


  def validate_rows(csv_data)
    
    count_row = 0
    parsed_file = CSV::parse(csv_data)
    validate_cols = parsed_file[0]
    cols_len = validate_cols.length
    data_type = []
    a = 0
    parsed_file.each  do |row|

      if cols_len != row.length
        count_row = 1
      else
        for i in 0..cols_len
          if a <= 0
            render text: row[i]         
          end
          a  = 1
        end
      end
      
    end 
    count_row    
  end

end
