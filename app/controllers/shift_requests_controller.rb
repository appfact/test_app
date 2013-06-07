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
    @shift = Shift.find(params[:shift_request][:shiftx_id])
    @shift_request = @shift.shift_requests.find_by_worker_id(params[:shift_request][:worker_id])
    @shift_request.manager_id = params[:shift_request][:manager_id]
    @shift_request.manager_status = params[:shift_request][:manager_status]
    if @shift_request.save
      flash[:success] = "you approved this shift"
      redirect_to @shift
    else
      flash[:error] = "something went wrong"
      redirect_to '/shifts'
    end
  end

  def show
  end

  def index
  end
end
