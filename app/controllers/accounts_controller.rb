class AccountsController < ApplicationController
  
  before_filter :authenticate_user!, except: [:show]
  before_filter :authorize, only: [:edit, :update, :destroy]

  def show
    @readme = @account.core_files.readme.first
    @license = @account.core_files.license.first
  end

  def edit
  end
  
  def new
    @account = Account.new
  end

  def create    
    @account = Account.new(params[:account])
    @account.license = params[:license]
    gon.errors = @account.errors     
    if @account.save   
      flash[:notice] = t("c.s")
      redirect_to root_url, :locals => {:flash => flash}
    else
      flash[:error] = t("c.f")
      render action: "new", :locals => {:flash => flash}
    end
  end

  def update
    gon.errors = @account.errors
    if @account.update_attributes(params[:account])      
      flash[:notice] = t("u.s")
      redirect_to edit_account_path(@account.owner, @account.slug), :locals => {:flash => flash}      
    else
      flash[:error] = t("u.f")
      render action: "edit", :locals => {:flash => flash}      
    end
  end

  def destroy
    @account.destroy     
    redirect_to root_url, :locals => {:flash => flash}
  end

  def license_sample  
    if params[:license]
      file_name = params[:license] + ".txt"
      render text: File.read(File.join("public/sample_license/#{file_name}"))
    end
  end

  def transfer

    if params[:submit].present?

      user_account_check = has_valid_account params
      

      transfer_to = params[:owner]
      account_id =  params[:account]

      if !user_account_check.blank?
        user_details = user_account_check[0]
        
        owner_check = User.where(email: transfer_to ).limit(1)
        owner_check = owner_check[0]

        if owner_check
          Permission.where(account_id: user_details.id, role: "O")
                    .update_all(user_id: owner_check.id)

          Permissions.invite_transfer_owner(owner_check).deliver

        else            
          Permission.where(account_id: user_details.id, role: "O")
                    .update_all(email: transfer_to)


          user_info = {'email'=>transfer_to}
          user_info = OpenStruct.new user_info
          
          Permissions.invite_user(user_info).deliver    
        end
        flash[:success] = "Account successfully transfered to: #{transfer_to}" 
        redirect_to root_url         
      else
        flash[:warning] = "Error while transferring  #{account_id} to: #{transfer_to} " 
        redirect_to :back
      end 
    end
  end

  def has_valid_account(params)
    account = current_user.accounts.where(name: params[:account])
                                   .merge(Permission.has_account(true))    
  end
  
  private
  
  def authorize
    if !@is_admin
      redirect_to root_url, error: "Permission denied."
    end
  end

end
