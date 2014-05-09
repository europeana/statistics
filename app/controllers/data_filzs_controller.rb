class DataFilzsController < ApplicationController
  
  before_filter :authenticate_user!, :find_objects, except: [:json_data]
  before_filter :find_objects

  def index
    @data_filzs = Data::Filz.where(genre: nil).order("updated_at desc")
  end
    
  def csv
    send_data Core::Services.twod_to_csv(JSON.parse(@data_filz.content)), :type => "application/vnd.ms-excel", :filename => "#{@data_filz.file_file_name}.csv", :stream => false
  end
  
  def show
    redirect_to edit_data_filz_path(file_id: @data_filz)
  end
  
  def new
    @data_filz = Data::Filz.new
    @disable_footer = true
    render action: "form"
  end
  
  def create
    @data_filz = Data::Filz.new(params[:data_filz])
    if @data_filz.save
      flash[:notice] = t("c.s")
      redirect_to data_filzs_path, :locals => {:flash => flash}
    else
      gon.errors = @data_filz.errors 
      flash[:error] = t("c.f")
      render action: "form", :locals => {:flash => flash}
    end
  end
  
  def edit
    render action: "form"
  end
  
  def update
    if @data_filz.update_attributes(params[:data_filz])
      redirect_to data_filzs_path, notice: t("u.s")
    else
      gon.errors = @data_filz.errors 
      flash[:error] = t("c.f")
      render action: "form", :locals => {:flash => flash}
    end
  end
  
  def destroy
    @data_filz.destroy
    redirect_to data_filzs_path
  end

  def json_data
    respond_to do |format|
      format.json { render :json => @data_filz.to_json, head: "ok"  }
    end          
  end
    
  private
  
  def find_objects
    if params[:file_id].present? 
      @data_filz = Data::Filz.find(params[:file_id])
    end
  end
  
end
