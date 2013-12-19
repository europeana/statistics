class Permissions < ActionMailer::Base
  default from: "theviri01@gmail.com"

  def invite_user(user)
    @user = user
    mail(:to => user.email, :subject => "We Invite you to SignUp")
  end

  def invite_collaborator(user)
    mail(:to => user.email, :subject => "Collaborator msg here....")
  end

  def invite_transfer_owner(user)
    mail(:to => user.email, :subject => "Your account has been transfered msg here....")
  end

end
