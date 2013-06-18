class ShiftRequestsController < ApplicationController

  before_filter :signed_in_user
  
  def create
    @shift = Shift.find(params[:shift_request][:shiftx_id])
    if  params[:shift_request][:manager_id].nil?
        @shift.request!(params[:shift_request][:worker_id])
        flash[:success] = "Shift requested - you will be notified if your manager approves it"
        redirect_back_or @shift
      else
        if !params[:shift_request][:manager_id].nil?
          @shift.offer!(params[:shift_request][:worker_id],current_user.id)
          flash[:success] = "Shift has been offered to #{User.find(params[:shift_request][:worker_id]).name}"
          redirect_to "/shifts/" + @shift.id.to_s + "/offers"
        end
      end
  end

  def destroy
    @shift = Shift.find(params[:shift_request][:shiftx_id])
    @shift.unfollow!(current_user)
    flash[:success] = "You have cancelled your request for this shift"
    redirect_back_or @shift
  end

  def cancelrequest
    @shift = Shift.find(params[:shiftid])
    @shiftrequest = @shift.shift_requests.find(params[:id])
    @shiftrequest.destroy
    flash[:success] = "You cancelled your request for this shift"
    redirect_to '/requests'
  end

  def offerdestroy
    @shift = Shift.find(params[:id])
    if @shift.shift_requests.find_by_manager_id(current_user.id).destroy
      flash[:success] = "You have cancelled the offer - user has been informed"
      redirect_to "/shifts/" + @shift.id.to_s + "/offers"
    else
      flash[:error] = "Something went wrong, please try again"
      redirect_back_or @shift
    end
  end

 
  def update
    @shift = Shift.find(params[:shift_request][:shiftx_id])
    @shift_request = @shift.shift_requests.find_by_worker_id(params[:shift_request][:worker_id])
    @shift_request.manager_id = params[:shift_request][:manager_id]
    @shift_request.manager_status = params[:shift_request][:manager_status]
    if @shift_request.save
      if (@shift_request.manager_status && @shift_request.worker_status)
        @shift.fk_user_worker = params[:shift_request][:worker_id]
        if @shift.save
          flash[:success] = "You approved this shift. 
                #{User.find(@shift.fk_user_worker).name} will be informed"
        @shift_request.delete
          redirect_to @shift
        end
      else
        flash[:warning] = "something went wrong with updating the shift"
        redirect_to @shift
      end
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
