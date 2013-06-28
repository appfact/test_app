class StaticPagesController < ApplicationController
  before_filter :signed_in_user,  only: [:shifts, :newshift]
  before_filter :admin_user,     only: :newshift


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
      end
    end
  end

  def contact
  end



  def newshift
  	@user = current_user
  	@shift = current_user.shifts.build if signed_in?
  end

  private

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
end
