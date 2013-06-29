class UserMailer < ActionMailer::Base

default from: 'ShiftCloud <notifications@shiftcloud.co.uk>'

  def inform_user_added_to_network(user,admin)
    @user = user
    @admin = admin
    @firm = Firm.find(@admin.business_id)
    @url = "https://www.shiftcloud.co.uk/"
    mail(to: @user.email, subject: "You have been added to the network of #{@firm.name} #{@firm.branch}")
  end

  def send_new_created_user_password(user,password,firm)
    @user = user
    @firm = firm
    @password = password
    mail(to: @user.email, subject: 'Welcome to ShiftCloud!')
  end

  def welcome_admin(user)
    @user = user
    @url  = 'https://www.shiftcloud.co.uk'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

  def password_reset(user,password)
    @user = user
    @password = password
    @url = 'https://www.shiftcloud.co.uk'
    mail(to: @user.email, subject: 'Your password has been reset')
  end


end