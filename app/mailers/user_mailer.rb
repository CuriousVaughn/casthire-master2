class UserMailer < ActionMailer::Base
  layout 'application_mailer'

  default :from => '"Interview.io" <no-reply@interview.io>'

  def password_reset(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: "Reset Your Password"
  end

  def email_confirmation(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: "You're almost there! Please confirm your email"
  end
end
