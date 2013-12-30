class CmsImagesController < ApplicationController
  
  before_filter :authenticate_user!

  def create
    a = JSON.parse(params["file"].to_json)
    @cms_image = Cms::Image.new
    @cms_image.title = a["original_filename"]
    @cms_image.image_file = params[:file]
    if @cms_image.save
      respond_to do |format|
        if params[:cms_image]
          format.html{redirect_to cms_images_path(file_id: @cms_image.slug), notice: t("c.s")}
        else          
          format.json { render json: {filename: @cms_image.image_file_url, error: ""}}
        end   
      end
    else
      respond_to do |format|
        if params[:cms_image]
          format.html{render action: "new", notice: t("c.s")}
        else          
          format.json { render json: {filename: "", error: @cms_image.errors}}
        end   
      end        
    end
  end

end
