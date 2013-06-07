class ShiftsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

 def create
    @shift = current_user.shifts.build(params[:shift])
    @shift.business_id = current_user.business_id
    if @shift.save
      flash[:success] = "Shift created!"
      redirect_to '/shifts'
    else
     # flash[:error] = "Shift could not be created - please try again"
     # taking out the flash error because think it interferes with validation errors
      render 'static_pages/newshift'
    end
 end

  def destroy
    @shift.destroy
    redirect_to '/shifts'
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def requests
    @shift = Shift.find(params[:id])
    @title = "Requests for shift #{@shift.id} - #{@shift.role} - #{@shift.start_date}"
    @shift_requests = @shift.shift_requests.paginate(page: params[:page])
    render 'show_requests'
  end

  private

  def correct_user
    @shift = current_user.shifts.find_by_id(params[:id])
    redirect_to root_url if @shift.nil?
  end
end