class StaticPagesController < ApplicationController
  before_filter :signed_in_user,  only: [:shifts, :newshift]
  before_filter :admin_user,     only: :newshift
  before_filter :business_user_not_completed_signup


  def home
    if signed_in?
      if current_user.admin?
        @availableshifts = available_shifts
        @firm = Firm.find(current_user.business_id)
        @numberinnetwork = @firm.firm_permissions.where(status:true)
        @openshifts = @firm.shifts.where(fk_user_worker: nil)
        @openshiftsweek = @firm.shifts.where(fk_user_worker: nil).where('start_datetime > ? AND start_datetime < ?', 
                Time.now.to_datetime, (Time.now.end_of_day + 7.days).to_datetime)
        @shiftrequests = @firm.shift_requests.where('manager_status is ?', nil)
      else
        @permissionsarray = [] 
        current_user.firm_permissions.where(status: true).each do |permission|
          @permissionsarray.push(permission.firm_id)
        end
        @openshifts = Shift.where('firm_id in (?)', @permissionsarray).where(fk_user_worker: nil)
        @openshiftsweek = Shift.where('firm_id in (?)', @permissionsarray).where(fk_user_worker: nil).where('start_datetime > ? AND start_datetime < ?', 
                Time.now.to_datetime, Time.now.end_of_day + 7.days)
        @availableshifts = Shift.where(fk_user_worker: nil).where('start_datetime > ?',Time.now.to_datetime)
              .where('firm_id in (?)', @permissionsarray)
        @offeredshifts = sp_available_shifts_offers
        @myshifts = Shift.where('fk_user_worker = ? AND end_datetime > ? AND start_datetime < ?',
                current_user.id, Time.now.to_datetime, Time.now.to_datetime + 7.days)
        @allmyshifts = Shift.where('fk_user_worker = ? AND start_datetime > ?', current_user.id, Time.now.to_datetime)
      end
    end
  end

  def contact
  end



  def newshift
  	@user = current_user
  	@shift = current_user.shifts.build if signed_in?
  end

  def resetpassword
  end

  def resetpasswordaction
    @user = User.find_by_email(params[:email])
    if @user.nil?
      flash[:error] = "Email not recognised"
      render 'resetpassword'
    else
      password_reset(@user)
      flash[:success] = "Your password was reset - please check your email for your new password"
      redirect_to '/home'
    end
  end

  def findoutmore
  end

  private

  def password_reset(user)
    @password = ('a'..'z').to_a.shuffle[0..7].join
    user.update_attributes(password: @password, password_confirmation: @password)
    UserMailer.password_reset(user,@password).deliver
  end

  def admin_user
  	unless current_user.admin?
  		flash[:error] = "You must be admin to create shifts"
  		redirect_to '/shifts'
  	end
  end


  def available_shifts
    @permissionsarray = []
    @userspermissions = current_user.firm_permissions.where(status: true)
    #move these variables to helpers
    @userspermissions.each do |permission|
      @permissionsarray.push(permission.firm_id)
    end
    return Shift.where("firm_id in (?) AND fk_user_worker is ? 
                  AND start_datetime > ? AND allocation_type in (1,2)", @permissionsarray, nil, Time.now.to_datetime)
  end

  def sp_available_shifts_offers
    @user = current_user
    @offersarray = []
    @useroffers = @user.shift_requests.where(worker_status: nil, manager_status: true)
    @useroffers.each do |offer|
      @offersarray.push(offer.shift_id)
    end
    return Shift.where('id in (?) AND fk_user_worker is ?', @offersarray, nil)
  end

  def business_user_not_completed_signup
    if signed_in_user
    if current_user.business_id = "ASSA{}{}{345345[]]]"
      flash[:info] = "Please complete your sign up"
      redirect_to new_firm_path
    end
  end
  end

end
