class ProvidersController < ApplicationController
  # GET /providers
  # GET /providers.json
  def index
    @providers = Provider.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @providers }
    end
  end

  # GET /providers/1
  # GET /providers/1.json
  def show
    @provider = Provider.find(params[:id])
    @cms_article = Cms::Article.where(title: @provider.name).last
    redirect_to cms_article_path(@cms_article.slug)
  end

  # GET /providers/new
  # GET /providers/new.json
  def new
    @provider = Provider.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @provider }
    end
  end

  # GET /providers/1/edit
  def edit
    @provider = Provider.find(params[:id])
  end

  # POST /providers
  # POST /providers.json
  def create
    @provider = Provider.new(params[:provider])
    page_builder = params[:update_data]
    if @provider.save
      #if page_builder == "yes"
      system "bundle exec rake page_generator:add_provider[#{@provider.name},#{@provider.provider_id},#{@provider.provider_type}] &"
      #@provider.delay().generate_page(@provider.name, @provider.provider_id, @provider.provider_type)
      #end
      @cms_article = Cms::Article.where(title: @provider.name).last
      redirect_to providers_path, notice: "Page is started generating, take several seconds"      
    else
      format.html { render action: "new" }
    end
  end

  # PUT /providers/1
  # PUT /providers/1.json
  def update
    @provider = Provider.find(params[:id])
    page_builder = params[:update_data]
    if @provider.update_attributes(params[:provider])
      #if page_builder == "yes"
        system "bundle exec rake page_generator:add_provider[#{@provider.name},#{@provider.provider_id},#{@provider.provider_type}] &"
        #@provider.delay().generate_page(@provider.name, @provider.provider_id, @provider.provider_type)
      #end
      @cms_article = Cms::Article.where(title: @provider.name).last
      if !@cms_article.nil?
        redirect_to cms_article_path(@cms_article.slug)
      else
        redirect_to :back
      end

    else
      format.html { render action: "edit" }
    end
  end

  # DELETE /providers/1
  # DELETE /providers/1.json
  def destroy
    @provider = Provider.find(params[:id])
    @provider.destroy

    respond_to do |format|
      format.html { redirect_to providers_url }
      format.json { head :no_content }
    end
  end
end
