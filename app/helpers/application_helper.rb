module ApplicationHelper   
  
  def signed_in?
    !current_user.blank?
  end
  
end