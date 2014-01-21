class CmsArticlesController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :find_objects

  def index    
    @core_tags = Cms::Article.select('tag, position').order(:position).pluck(:tag).uniq
    @default_tag_name = ""
    if params[:tag].present?
      if params[:tag].nil? || params[:tag].blank? || params[:tag] == "All-Empty-Tags"
        @default_tag_name = "All-Empty-Tags"
        @cms_article = Cms::Article.where(tag: nil).first
      else
        @default_tag_name = params[:tag]
        @cms_article = Cms::Article.where(tag: params[:tag]).first
      end
    else
      @cms_article = Cms::Article.where(home_page: true).first
      @default_tag_name = @cms_article.tag
    end
    gon.cms_article = @cms_article
  end

  def show
    gon.width = ""
    gon.height = ""
  end

  def new
    @cms_article = Cms::Article.new
    @viz_vizs = Viz::Viz.all
    gon.width = "300px"
    gon.height = "300px"
  end

  def edit
    gon.width = "300px"
    gon.height = "300px"    
  end
  
  def create
    @cms_article = Cms::Article.new(params[:cms_article])
    @cms_article.position = 0
    @cms_article.is_published = false
    if params[:commit] == "Publish"
      @cms_article.is_published = params[:commit] == "Publish" ? true : false
    end
    @cms_article.description.to_s.html_safe
    if @cms_article.save
      redirect_to cms_article_path(file_id: @cms_article.slug), notice: t("c.s")
    else
      @viz_vizs = Viz::Viz.all
      gon.errors = @cms_article.errors
      gon.width = "300px"
      gon.height = "300px"      
      render action: "new"
    end
  end

  def update
    @cms_article.is_published = false
    if params[:commit] == "Publish"
      @cms_article.is_published = true
    end
    @cms_article.description.to_s.html_safe
    if @cms_article.update_attributes(params[:cms_article])
      redirect_to cms_article_path(file_id: @cms_article.slug), notice: t("u.s")
    else
      gon.width = "300px"
      gon.height = "300px"      
      @viz_vizs = Viz::Viz.all
      render action: "edit"
    end
  end

  def destroy
    @cms_article.destroy
    redirect_to root_url
  end

  def sort    
    params[:sort].each_with_index do |id, index|      
      positionx = index+1
      Cms::Article.where(tag: id).update_all(position: positionx)
    end
    render nothing: true
  end  
  
  private
  
  def find_objects
    if params[:file_id].present? 
      @cms_article = Cms::Article.find(params[:file_id])
    end    
    @viz_vizs = Viz::Viz.all
  end
    
end
