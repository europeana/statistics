class VizVizsController < ApplicationController
  
  before_filter :authenticate_user!, :find_objects
  
  def index
    @viz_vizs = Viz::Viz.all
  end
  
  def map
  end

  def show
    if @viz_viz.map.blank? and current_user.present?
      redirect_to map_viz_viz_path(file_id: @viz_viz.slug)
    end
  end

  def new
    @viz_viz = Viz::Viz.new
  end
  
  def edit
    if @viz_viz.map.blank?
      redirect_to map_viz_viz_path(file_id: @viz_viz.slug)
    end
    @mapped_output = JSON.parse(@viz_viz.mapped_output)
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
    redirect_to viz_vizs_path
  end
  
  private
  
  def find_objects
    @data_filzs = Data::Filz.all
    if params[:file_id].present? 
      @viz_viz = Viz::Viz.find(params[:file_id])
    end
  end
  
end
