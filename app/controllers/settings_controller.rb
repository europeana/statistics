class SettingsController < ApplicationController

  before_filter :authenticate_user!
  def index 
  end

  def show
  end

  def edit
    @setting = Setting.first
  end
  def template
    @template = JSON.parse(Setting.last.page_builder_config)
  end 
  def update_template
    template = params[:json_data]
    Setting.last.update_attributes({page_builder_config: template})
    redirect_to template_settings_path
  end

  def update
    @setting = Setting.first
    if params[:setting][:masonry] == "m"
      params[:setting][:masonry] = true
    else 
      params[:setting][:masonry] = false
    end

    if params[:remove_image].present?
      if params[:remove_image] == "on"
        @setting.remove_image!
      end
    end

    if @setting.update_attributes(params[:setting])      
      redirect_to edit_settings_path, notice: "Setting Updated"
    end
  end 
  
end
