class RegistrationsController < Devise::RegistrationsController

  def create
    @user = User.new(params[:user])
    if @user.save
      @permissions = Permission.where(email: @user.email)
      if @permissions.first.present?
        @permissions.update_all(user_id: @user.id)
      end
      redirect_to root_url, notice: "A message with a confirmation link has been sent to your email address. Please open the link to activate your account."
    else
      gon.errors = @user.errors
      super
    end
  end

end
