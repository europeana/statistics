class CmsArticlesController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :find_objects

  def index
    @cms_articles = Cms::Article.all
  end

  def show
  end

  def new
    @cms_article = Cms::Article.new
    @viz_vizs = Viz::Viz.all
  end

  def edit
    @viz_vizs = Viz::Viz.all
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
      render action: "edit"
    end
  end

  def destroy
    @cms_article.destroy
    redirect_to cms_articles_path
  end
  
  private
  
  def find_objects
    if params[:file_id].present? 
      @cms_article = Cms::Article.find(params[:file_id])
    end
  end
    
end
