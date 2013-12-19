class UsersController < ApplicationController
  
  def login

    if params[:action]    
      username = params[:user][:username]
      password = params[:user][:password]
    
      user = User.authenticate(username,password)

      if user
        session[:user_id] = user.id
        session[:user_name] = user.name
        session[:user_email] = user.email
        redirect_to dashboard_path, notice: "Login Successfully"
      else 
        redirect_to root_url, notice: "Invalid login!!!" 
      end
      
    end

  end

end
