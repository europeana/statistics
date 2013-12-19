class UsersController < ApplicationController
    
  def login

    if params[:login].present?

      user = User.authenticate(params[:username],params[:password])
      notice = ""      

      if !user.blank?
        if user.verified_tour.nil?
          notice = "Your account still not verified"          
        else
          if user.verified_tour <= 0
            redirect_to users_login_path, :notice => "Your account is not activated yet !!!"          
            return
          end
          session[:user_id] = user.id
          session[:user_name] = user.name
          session[:user_email] = user.email_id
          if user.admin > 0
            session[:user_admin] = user.admin
          end
          redirect_to tours_path, :notice => "#{notice}"          
        end
      else 
        notice = "Invalid login!!!"  
        redirect_to users_login_path, :notice => "#{notice}"
      end
      
    end

  end

end
