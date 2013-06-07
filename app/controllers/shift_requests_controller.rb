class ShiftRequestsController < ApplicationController
  def create
    @shift = Shift.find(params[:shift_request][:shiftx_id])
    @shift.request!(params[:shift_request][:worker_id])
    flash[:success] = "Shift requested - you will be notified if your manager approves it"
    redirect_back_or @shift
  end

  def destroy
    @shift = Shift.find(params[:shift_request][:shiftx_id])
    @shift.unfollow!(current_user)
    flash[:success] = "You have cancelled your request for this shift"
    redirect_back_or @shift
  end

  def update
  end

  def show
  end

  def index
  end
end
