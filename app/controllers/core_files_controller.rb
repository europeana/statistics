class CoreFilesController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show, :index, :raw]
  before_filter :find_objects
  before_filter :authorize, except: [:index, :show, :license, :readme, :raw]
  
  def index
    @core_files = @account.core_files.where(category: @folder)
  end
  
  def apis
  end
  
  def show
  end
  
  def raw
    render layout: "no_html"
  end
  
  def new
    @core_file = Core::File.new
    @core_file.commit_message = "First commit"
  end
  
  def create
    @core_file = Core::File.new(params[:core_file])
    if @core_file.save
      flash[:notice] = t("c.s")
      redirect_to user_account_core_file_path(@account.owner, @account.slug, folder_id: @folder, file_id: @core_file.slug), :locals => {:flash => flash}
    else
      gon.errors = @core_file.errors 
      flash[:error] = t("c.f")
      render action: "new", :locals => {:flash => flash}
    end
  end
  
  def edit
  end
  
  def update
    if @core_file.update_attributes(params[:core_file])
      redirect_to user_account_core_file_path(@account.owner, @account.slug, folder_id: @folder, file_id: @core_file.slug), notice: t("u.s")
    else
      gon.errors = @core_file.errors
      render action: "edit" 
    end
  end
  
  def destroy
    @core_file.destroy
    redirect_to user_account_core_files_path(@account.owner, @account.slug, folder_id: @folder)
  end
  
  def license
    @core_file = @account.core_files.license.first
    @folder = "_"
    @editor = "text"
    @disable_delete = true
    render "show"
  end
  
  def readme
    @core_file = @account.core_files.readme.first
    @folder = "_"
    @editor = "text"
    @disable_delete = true
    render "show"
  end
  
  private
  
  def find_objects
    if params[:folder_id].present?
      @folder = params[:folder_id]
      if params[:file_id].present? 
        @core_file = @account.core_files.find(params[:file_id])
      end
    end
    @editor = "csv"
  end
  
  def authorize
    if !@is_admin
      redirect_to root_url, error: "Permission denied."
    end
  end
  
end
