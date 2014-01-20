class CmsArticlesController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :find_objects

  def index
    @core_tag = params[:tag].blank? ? Core::Tag.where(name: "Overview").first : Core::Tag.find(params[:tag])
    @cms_articles = Cms::Article.where(core_tag_id: @core_tag.id)
    gon.cms_articles = @cms_articles
  end

  def show
    gon.width = ""
    gon.height = ""
  end

  def new
    @core_tag = params[:tag].blank? ? Core::Tag.where(name: "Overview").first : Core::Tag.find(params[:tag])
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
    @cms_article.is_published = false
    if params[:commit] == "Publish"
      @cms_article.is_published = params[:commit] == "Publish" ? true : false
    end
    @cms_article.description.to_s.html_safe
    if @cms_article.save
      redirect_to cms_article_path(file_id: @cms_article.slug), notice: t("c.s")
    else
      @viz_vizs = Viz::Viz.all
      @core_tag = Core::Tag.find(@cms_article.core_tag_id)
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
  
  private
  
  def find_objects
    if params[:file_id].present? 
      @cms_article = Cms::Article.find(params[:file_id])
    end
    @core_tags = Core::Tag.order(:sort_order)
    @viz_vizs = Viz::Viz.all
  end
    
end
