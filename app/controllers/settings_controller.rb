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
    if @setting.update_attributes(params[:setting])
      redirect_to root_url, notice: "Setting Updated"
    end
  end  

end
