class ConfirmationsController < Devise::ConfirmationsController
	def new
		super
	end

	def create
    @user = User.new(params[:user])
    super
	end

end
