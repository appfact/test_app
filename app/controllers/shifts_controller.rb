class ShiftsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:destroy, :create]
  before_filter :correct_user,   only: :destroy

 def create
    @shift = current_user.shifts.build(params[:shift])
    @shift.business_id = current_user.business_id
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
    redirect_to '/shifts'
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def requests
    @shift = Shift.find(params[:id])
    @title = "Requests for shift #{@shift.id} - #{@shift.role} - #{@shift.start_date}"
    @shift_requests = @shift.shift_requests.find_all_by_worker_status_and_manager_status(true,nil)
    render 'show_requests'
  end

  def offers
    @shift = Shift.find(params[:id])
    @title = "Offers for shift #{@shift.id} - #{@shift.role} - #{@shift.start_date}"
    @shift_offers = @shift.shift_requests.find_all_by_worker_status_and_manager_status(nil,true)
    render 'show_offers'
  end

  def remove_worker
    @shift = Shift.find(params[:id])
    @shift.fk_user_worker = nil
    @shift.save
    flash[:success] = "You cleared this shift, user has been informed"
    redirect_back_or @shift
  end


  private

  def correct_user
    @shift = Shift.find_by_id(params[:id])
    redirect_to root_url unless @shift.business_id == current_user.business_id 
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end