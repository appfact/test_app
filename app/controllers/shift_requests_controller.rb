class ShiftRequestsController < ApplicationController

  before_filter :signed_in_user
  before_filter :user_can_interact_with_request
  
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

  def rejectoffer
    @shift = Shift.find(params[:shiftid])
    @shiftrequest = @shift.shift_requests.find(params[:id])
    @shiftrequest.update_attributes(worker_status: false)
    flash[:success] = "You rejected the offer for shift ##{@shift.id} - #{@shift.role}"
    redirect_to '/offers'
  end

  def acceptoffer
    @shift = Shift.find(params[:shiftid])
    if @shift.fk_user_worker.nil?
      @shiftrequest = @shift.shift_requests.find(params[:id])
      @shiftrequest.destroy
      @shift.update_attributes(fk_user_worker: current_user.id)
      flash[:success] = "You accepted the offer for shift ##{@shift.id} - #{@shift.role} and you are now assigned this shift"
      redirect_to '/offers'
    else
      flash[:error] = "Sorry - this shift has already been assigned to someone else - offer no longer valid"
      redirect_to '/offers'
    end
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

  def user_request_from_available_shifts
    @user = current_user
    @shift = Shift.find(params[:shiftid])
    if (@shift.shift_requests.find_by_worker_id(@user.id).nil? && @shift.fk_user_worker.nil?)
      if @shift.shift_requests.create!(worker_id: @user.id, worker_status: true)
        check_if_user_got_shift(@shift)
        redirect_to '/availableshifts'
        return
      else
        flash[:error] = "Your request failed - please try again"
        redirect_to '/availableshifts'
        return
      end
    else
      if !@shift.shift_requests.find_by_worker_id_and_manager_status(@user.id,true).nil?
        check_if_user_got_shift(@shift)
        return
      end
      flash[:error] = "Something went wrong, you may already have a request for this shift, or it
                      may no longer be available"
      redirect_to '/availableshifts'
    end                
  end

  def cancel_request_from_available_shifts
    @user = current_user
    @shift = Shift.find(params[:shiftid])
    if @shift.shift_requests.find_by_worker_id(@user.id).nil?
      flash[:error] = "Request could not be cancelled - you do not have a request for this shift"
      redirect_to '/availableshifts'
      return
    end
    @shift.shift_requests.find_by_worker_id(@user.id).destroy
    flash[:success] = "Your request was cancelled"
    redirect_to '/availableshifts'
  end


private

  def check_if_user_got_shift(shift)
    if !shift.fk_user_worker.nil?
      flash[:error] = "something went wrong, shift no longer available"
      return
    else
      if (shift.allocation_type == 1 || !shift.shift_requests.find_by_worker_id_and_manager_status(current_user, true).nil?)
        shift.update_attributes(fk_user_worker: current_user.id)
        shift.shift_requests.find_by_worker_id(current_user.id).destroy
        flash[:success] = "Your request was successful - you are now allocated shift ##{shift.id} - #{@shift.role}"
        return
      end
    end
    flash[:success] = "You requested shift ##{shift.id} - #{shift.role}"
  end

  def user_can_interact_with_request
  end

end
