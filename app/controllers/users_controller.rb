class UsersController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show]
  before_filter :authorize, except: [:show]
  
  def show
    @is_breadcrumb_enabled = false
    @my_accounts     = @user.my_accounts
    @shared_accounts = @user.shared_accounts
  end

  def edit
  end
  
  def integrations
    @core_oauths = current_user.core_oauths
    @data_ga_accounts = current_user.data_ga_accounts
  end
  
  def update
    if @user.update_attributes(params[:user])
      redirect_to edit_user_path, notice: t("u.s")
    else
      gon.errors = @user.errors
      render action: "edit" 
    end
  end
  
  private

  def authorize
    if @user.present?
      if current_user.id != @user.id
        redirect_to root_url, error: "Permission denied."
      end
    else
      @user = current_user
    end
  end

end
