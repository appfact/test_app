class UserMailer < ActionMailer::Base

default from: 'ShiftCloud <notifications@shiftcloud.co.uk>'

  def welcome_admin(user)
    @user = user
    @url  = 'http://...com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def send_new_created_user_password(user,password)
  	@user = user
  	@firm = Firm.find(current_user.firm_id)
  	@password = password
  	mail(to: @user.email, subject: 'Welcome to ShiftCloud!')
  end

end