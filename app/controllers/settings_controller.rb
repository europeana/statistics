class SettingsController < ApplicationController

  before_filter :authenticate_user!
  def index 
  end

  def show
  end

  def edit
    @setting = Setting.first
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
