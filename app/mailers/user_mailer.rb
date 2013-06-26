class UserMailer < ActionMailer::Base

default from: 'notifications@shiftcloud.co.uk'

  def welcome_email(user)
    @user = user
    @url  = 'http://...com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

end