class ShiftMailer < ActionMailer::Base

default from: 'ShiftCloud <notifications@shiftcloud.co.uk>'

  def assigned_shift(user,shift)
    @user = user
    @firm = Firm.find(shift.firm_id)
    @url  = 'http://...com/shifts'
    mail(to: @user.email, subject: "You have been assigned a shift @ #{@firm.name} #{@firm.branch}")
  end

  def removed_shift(user,shift)
  	@user = user
    @firm = Firm.find(shift.firm_id)
    @url  = 'http://...com/shifts'
    mail(to: @user.email, subject: "Your shift on #{@shift.start_datetime.strftime("%d %b %H:%M")} 
    				@ #{@firm.name} #{@firm.branch} has been cancelled")
  end

end