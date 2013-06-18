class ShiftsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:destroy, :create]
  before_filter :correct_user,   only: :destroy

 def create
    @firm = Firm.find(current_user.business_id)
    @shift = @firm.shifts.build(params[:shift])
    @shift.user_id = current_user.id
    if @shift.save
      flash[:success] = "Shift created!"
      redirect_to @shift
    else
     # flash[:error] = "Shift could not be created - please try again"
     # taking out the flash error because think it interferes with validation errors
      render 'static_pages/newshift'
    end
 end

  def destroy
    @shift.destroy
    flash[:success] = "You deleted the shift ##{@shift.id} - #{@shift.role}"
    @firm = Firm.find(current_user.business_id)
    redirect_to shifts_firm_path(@firm)
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def requests
    @shift = Shift.find(params[:id])
    @title = "Requests for shift #{@shift.id} - #{@shift.role} - #{@shift.start_datetime}"
    @shift_requests = @shift.shift_requests.find_all_by_worker_status_and_manager_status(true,nil)
    render 'show_requests'
  end

  def offers
    @shift = Shift.find(params[:id])
    @available_users_items = @shift.available_users.paginate(page: params[:page])
    @title = "Offers for shift #{@shift.id} - #{@shift.role} - #{@shift.start_datetime}"
    @shift_offers = @shift.shift_requests.find_all_by_worker_status_and_manager_status(nil,true)
  end

  def assign
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    @assignable_users_items = @firm.firm_permissions.where(:status => true).paginate(page: params[:page])
  end

  def remove_worker
    @shift = Shift.find(params[:id])
    @shift.fk_user_worker = nil
    if @shift.save
      flash[:success] = "You cleared this shift, user has been informed"
      redirect_back_or @shift
    else
      flash[:error] = "Something went wrong, worker not removed, please try again"
      redirect_back_or @shift
    end
  end

  def assign_worker
    @shift = Shift.find(params[:id])
    if !@shift.fk_user_worker.nil?
      flash[:error] = "Shift has already been assigned. Please remove worker from shift before reassigning."
      redirect_to assign_shift_path(@shift)
      return
    end
    if User.find(params[:workerid]).nil?
      flash[:error] = "An error has occurred, user not recognised"
      redirect_to assign_shift_path(@shift)
    else
      @shiftworker = User.find(params[:workerid])
      @shift.update_attribute(:fk_user_worker, @shiftworker.id)
      flash[:success] = "Shift was assigned to #{@shiftworker.name}"
      redirect_to @shift
    end
  end

 

  private

  def correct_user
    @shift = Shift.find_by_id(params[:id])
    redirect_to root_url unless @shift.firm_id == current_user.business_id.to_i
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end