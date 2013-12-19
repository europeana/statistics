class StaticPagesController < ApplicationController

  def index
    if signed_in?
      @new_user        = current_user.accounts.limit(1).first.blank? ? true : false
      @my_accounts     = current_user.my_accounts
      @shared_accounts = current_user.shared_accounts
    end    
  end
    
  #------------- APIs ----------------
  
  def tinycon
    return 6
  end
      
end
