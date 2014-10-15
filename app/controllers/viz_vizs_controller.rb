class VizVizsController < ApplicationController
  
  #before_filter :authenticate_user!, except: [:generate_chart]
  before_filter :find_objects
  
  def index
    @viz_vizs = Viz::Viz.find(:all, order: "updated_at desc")
  end
  
  def map
  end

  def show
    if @viz_viz.map.blank?
      redirect_to map_viz_viz_path(file_id: @viz_viz.slug)
    else
      redirect_to edit_viz_viz_path(file_id: @viz_viz.slug)
    end
    #@mapped_output = JSON.parse(@viz_viz.mapped_output)
    #gon.csv_data = Core::Services.twod_to_csv(@mapped_output)
  end

  def new
    @viz_viz = Viz::Viz.new
  end
  
  def edit
    if @viz_viz.map.blank?
      redirect_to map_viz_viz_path(file_id: @viz_viz.slug)
    end
    if @viz_viz.chart == "Grouped Column Chart - Filter"
      @mapped_output = Viz::Viz.formatInColumnGroupChart(JSON.parse(Data::Filz.find(@viz_viz.data_filz_id).content), Date.today.year)
    else
      @mapped_output = JSON.parse(@viz_viz.mapped_output)
    end
    
    gon.csv_data = Core::Services.twod_to_csv(@mapped_output)
    gon.chart_type = @viz_viz.chart
    gon.mapped_output = {}
    gon.mapped_output["#pie-chart"] = @mapped_output
    gon.lineChartData = {}
    gon.lineChartData["#pie-chart"] = gon.csv_data
  end

  def embed
    @mapped_output = JSON.parse(@viz_viz.mapped_output)
    gon.csv_data = Core::Services.twod_to_csv(@mapped_output)
    gon.chart_type = @viz_viz.chart
    gon.mapped_output = {}
    gon.mapped_output["#embed-chart"] = @mapped_output
    gon.lineChartData = {}
    gon.lineChartData["#embed-chart"] = gon.csv_data
  end

  def create    
    @viz_viz = Viz::Viz.new(params[:viz_viz])
    if @viz_viz.save
      redirect_to map_viz_viz_path(file_id: @viz_viz.slug)
    else
      gon.errors = @viz_viz.errors 
      flash[:error] = t("c.f")
      render action: "new", :locals => {:flash => flash}
    end
  end
  
  def put_map
    @viz_viz.update_attributes(map: params[:data])
    redirect_to edit_viz_viz_path(@viz_viz.slug)
  end

  def update
    if @viz_viz.update_attributes(params[:viz_viz])
      if @viz_viz.map.blank?
        redirect_to map_viz_viz_path(file_id: @viz_viz.slug)
      else
        redirect_to viz_viz_path(file_id: @viz_viz.slug), notice: t("u.s")
      end
    else
      gon.errors = @viz_viz.errors
      if @viz_viz.map.blank?
        render action: "map" 
      else
        render action: "edit" 
      end
    end
  end
  
  def destroy
    @viz_viz.destroy
    redirect_to viz_vizs_path, notice: "Record deleted."
  end

  def generate_chart    
    if @viz_viz      
      if params[:gcolchart].present?
        if params[:gcolchart].blank? || params[:gcolchart].nil? || params[:gcolchart] == "0"
          params[:gcolchart] = Date.today.year
        end        
        mapped_output = Core::Services.twod_to_csv(Viz::Viz.formatInColumnGroupChart(JSON.parse(Data::Filz.find(@viz_viz.data_filz_id).content), params[:gcolchart]))
        mapped_output2 = mapped_output        
      elsif params[:mapschart].present?        
        if params[:mapschart].blank? || params[:mapschart].nil? || params[:mapschart] == "0"
          params[:mapschart] = Date.today.year
        end
        if params[:mapschartquarter].blank? || params[:mapschartquarter].nil? || params[:mapschartquarter] == "0"
          params[:mapschartquarter] = "q#{((((Date.today.at_beginning_of_month).month - 1) / 3) + 1)}"
        end
        mapped_output = Core::Services.twod_to_csv(Viz::Viz.formatInMapsChart(JSON.parse(Data::Filz.find(@viz_viz.data_filz_id).content), params[:mapschart], params[:mapschartquarter]))
        mapped_output2 = mapped_output        
      else
        mapped_output = JSON.parse(@viz_viz.mapped_output)
        mapped_output << [" ", 0.00001] if @viz_viz.chart == "Pie Chart" and mapped_output.count < 3          
        mapped_output2 = mapped_output        
        mapped_output = Core::Services.twod_to_csv(mapped_output)
      end            
      json_data = { "chart_type" => @viz_viz.chart, "chart_data" => mapped_output , "mapped_output" => mapped_output2}
    else
      json_data = {}      
    end
    if params[:gcolchart].present?
      render text: mapped_output
    else
      respond_to do |format|
        format.json { render :json => json_data.to_json, head: "ok"  }
      end    
    end
  end
  
  private  
  def find_objects
    @data_filzs = Data::Filz.where(genre: nil)
    if params[:file_id].present? 
      @viz_viz = Viz::Viz.find(params[:file_id])
    end
  end
  
end
