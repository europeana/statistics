class SessionsController < Devise::SessionsController
  
  def create
    @user = User.new(params[:user])
    gon.errors = @user.errors
    super
  end

  def new
    @user = User.new
    gon.errors = @user.errors
    super    
  end

end
