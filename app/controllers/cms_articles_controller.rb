class CmsArticlesController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :find_objects

  def index        
    @cms_articles = Cms::Article.where("tag IS NOT null AND tag <> ''").order(:position)
    if params["tag"].present?
      @cms_other_articles = Cms::Article.where("tag IS null OR tag = ''")
      @selected_article = "other"
      @setting = Setting.first
    else
      cms = Cms::Article.where(home_page: true).first
      if cms
        redirect_to "/#{cms.slug}"  
      end      
    end
  end

  def allArticles
    
  end

  def show
    @cms_articles = Cms::Article.where("tag IS NOT null AND tag <> ''").order(:position)
    @selected_article = @cms_article.slug
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
      Cms::Article.where(slug: id).update_all(position: positionx)
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
