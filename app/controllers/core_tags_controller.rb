class CoreTagsController < ApplicationController
  
  before_filter :authenticate_user!, :find_object
  
  def index
    @core_tag = Core::Tag.new
  end

  def edit
  end

  def create
    @core_tag = Core::Tag.new(params[:core_tag])
    if @core_tag.save
      redirect_to core_tags_path, notice: 'Added.'
    else
      render action: "index" 
    end
  end

  def update
    if @core_tag.update_attributes(params[:core_tag])
      redirect_to core_tags_path, notice: 'Updated.' 
    else
      render action: "edit"
    end
  end

  def destroy
    @core_tag.destroy
    redirect_to core_tags_path
  end
  
  private
  
  def find_object
    if params[:tag_id].present?
      @core_tag = Core::Tag.find(params[:tag_id])
    end
    @core_tags = Core::Tag.order(:sort_order)
  end
  
end