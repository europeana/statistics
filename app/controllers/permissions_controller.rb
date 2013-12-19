class PermissionsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :find_permission, only: [:show, :edit, :update, :expire, :destroy]

  def index 
    @permissions = @account.permissions.collaborators
    @permission = Permission.new
  end

  def create     
    invitee_detail1 = Core::Services.get_user(params[:permission]["email"]) 
    invitee_detail = invitee_detail1[0]
    
    @permission = @account.permissions.build(params[:permission])
    if invitee_detail
      @permission['user_id'] = invitee_detail.id
    end
    if @permission.save      
      if invitee_detail
        Permissions.invite_collaborator(invitee_detail).deliver
      else
        Permissions.invite_user(@permission).deliver    
      end
      redirect_to user_account_permissions_path(@account.creator, @account), notice: t("c.i")
    else 
      @permissions = @account.permissions.collaborators     
      gon.errors = @permission.errors  
      render action: "index" 
    end
  end

  def destroy
    Core::Alert.log(@permission.account_id, "delete_user", "User", @permission.user_id)
    @permission.destroy
    redirect_to user_account_permissions_path(@account.creator, @account), notice: t("d.e")
  end

  private
  
  def find_permission
    @permission = @account.permissions.find(params[:id])
  end

end