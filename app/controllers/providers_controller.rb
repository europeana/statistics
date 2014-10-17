class ProvidersController < ApplicationController
  # GET /providers
  # GET /providers.json
  before_filter :authenticate_user!
  def index
    #Provider.testing
    # sss
    #render json: Provider.testcsv
    # sssss
    Provider.testing_updater
    ssss
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
    if !@cms_article.nil?
      redirect_to cms_article_path(@cms_article.slug)
    end
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
    provider_name = params[:provider][:name]
    @provider = Provider.where(name: provider_name).first
    if @provider.nil?
      @provider = Provider.new(params[:provider])
      if @provider.save
        if params[:run_builder].present?
          @provider.start_page_builder_process
        end
        redirect_to providers_path, notice: "Page is started generating, take several seconds"
      else
        format.html { render action: "new" }
      end
    else
      @provider.update_attributes(name: provider_name, provider_id: params[:provider][:provider_id], provider_type: params[:provider][:provider_type])
      if params[:run_builder].present?
        @provider.start_page_builder_process
        notice = "Page is started generating, take several seconds"
      else
        notice = "Provider Already Present. Updated Attributes"
      end
      redirect_to providers_path, notice: "#{notice}"
    end
  end

  # PUT /providers/1
  # PUT /providers/1.json
  def update
    @provider = Provider.find(params[:id])      
    if @provider.update_attributes(params[:provider])
      if params[:run_builder].present?
        @provider.start_page_builder_process                
      end
      redirect_to providers_path, notice: "Page is started generating, take several seconds"
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
