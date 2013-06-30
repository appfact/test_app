class ShiftsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:destroy, :create, :remove_worker, :series, :dais, :dsis, :rsis, :rais, :ais, :ais_to_worker,
                                    :newshift, :newshiftclone, :requests, :approve_request, :offers, :offer_shift_to_worker,
                                    :unoffer_shift_to_worker, :assign, :assign_worker, :edit, :update, :clone]
  before_filter :correct_user, except: [:newshift, :newshiftclone, :create]

  def newshift
    @firm = Firm.find(current_user.business_id)
    @shift = @firm.shifts.build(params[:shift])
    @shift.duration_mins = Time.now.beginning_of_day
  end

 def create
    @firm = Firm.find(current_user.business_id)
    @shift = @firm.shifts.build(params[:shift])
    @shift.user_id = current_user.id
    # check shift repeat details correct
    

    if @shift.save
      if @shift.repeat_type > 0
        @shift.update_attributes(series_id: @shift.id)
        create_repeat_shifts(@shift)
      end
      flash[:success] = "Shift created!"
      redirect_to @shift
    else
      flash[:error] = "Shift could not be created - please check you have entered the required info"
     # taking out the flash error because think it interferes with validation errors
      render 'newshift'
    end
 end

  def destroy
    @shift.destroy
    if !@shift.fk_user_worker.nil?
      @worker = User.find(@shift.fk_user_worker)
      ShiftMailer.cancelled_shift(@worker,@shift).deliver
    end
    flash[:success] = "You deleted the shift ##{@shift.id} - #{@shift.role}"
    @firm = Firm.find(current_user.business_id)
    redirect_to shifts_firm_path(@firm)
  end

  def show
    @shift = Shift.find(params[:id])
    @shift_series_items = Shift.where('series_id = ?',@shift.series_id)
  end

  def requests
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    flash[:error] = "This shift has already been assigned" unless @shift.fk_user_worker.nil? 
    @title = "Requests for shift #{@shift.id} - #{@shift.role} - #{@shift.start_datetime}"
    @shift_requests = @shift.shift_requests.where(:worker_status => true).where(:manager_status => nil)
  end

  def approve_request
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    if @shift.fk_user_worker.nil?
      @shiftrequest = @shift.shift_requests.find(params[:requestid])
      @requestuser = User.find(@shift.shift_requests.find(params[:requestid]).worker_id)
      @shiftrequest.update_attributes(manager_status: true, manager_id: current_user.id)
      @shift.update_attributes(fk_user_worker: @requestuser.id)
      ShiftMailer.assigned_shift(@requestuser,@shift).deliver
      flash[:success] = "You approved the request - shift now filled"
    else
      flash[:error] = "Could not approve request - shift already filled"
    end
    redirect_to shiftrequests_firm_path(@firm)
  end

  def reject_request
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    @shiftrequest = @shift.shift_requests.find(params[:requestid])
    @requestuser = User.find(@shift.shift_requests.find(params[:requestid]).worker_id)
    @shiftrequest.update_attributes(manager_status: false, manager_id: current_user.id)
    flash[:success] = "You rejected the request"
    redirect_to shiftrequests_firm_path(@firm)
  end

  def offers
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    @available_users_items = @firm.firm_permissions.where('status = ?', true).paginate(page: params[:page])
    @title = "Offers for shift #{@shift.id} - #{@shift.role} - #{@shift.start_datetime}"
    @shift_offers = @shift.shift_requests.find_all_by_worker_status_and_manager_status(nil,true)
  end

  def offer_shift_to_worker
    @shift = Shift.find(params[:id])
    @worker = User.find(params[:workerid])
    if !@shift.shift_requests.find_by_worker_id(@worker.id).nil?
      @request = @shift.shift_requests.find_by_worker_id(@worker.id)
      if @request.worker_status = true
        @shift.shift_requests.find_by_worker_id(@worker.id).delete
        @shift.update_attributes(fk_user_worker: params[:workerid])
        flash[:success] = "You offered shift to user and the user accepted the request. Shift now allocated to user."
        ShiftMailer.assigned_shift(@worker,@shift).deliver
        redirect_to @shift
      else
        flash[:error] = "You cannot offer this worker this shift because they have already rejected a request."
        redirect_to offers_shift_path(@shift)
      end
    else
      @shift.shift_requests.create(manager_status: true, manager_id: current_user.id, worker_id: @worker.id)
      flash[:success] = "You offered shift to #{@worker.name}"
      ShiftMailer.offered_shift(@worker,@shift).deliver
      redirect_to offers_shift_path(@shift)
    end
  end

  def unoffer_shift_to_worker
    @shift = Shift.find(params[:id])
    @worker = User.find(params[:workerid])
    @shift.shift_requests.find_by_worker_id(@worker.id).delete
    flash[:success] = "You cancelled your offer to #{@worker.name}"
    redirect_to offers_shift_path(@shift)
  end

  def user_request
    @shift = Shift.find(params[:id])
    if !@shift.fk_user_worker.nil?
      flash[:error] = "Error - this shift has already been assigned"
    elsif @shift.shift_requests.where(worker_id: current_user).where(worker_status: true).any?
      flash[:error] = "You have already requested this shift"
    elsif @shift.shift_requests.where(worker_id: current_user).where(worker_status: nil).any?
      @shift.shift_requests.find_by_worker_id(current_user.id).destroy
      @shift.update_attributes(fk_user_worker: current_user.id)
      flash[:success] = "Your request was successful and you are now assigned this shift"
    elsif @shift.allocation_type == 1
      @shift.update_attributes(fk_user_worker: current_user.id)
      flash[:success] = "Your request was successful and you are now assigned this shift"
    else @shift.shift_requests.create(worker_id: current_user.id, worker_status: true)
      flash[:success] = "You have requested this shift"
    end
    redirect_to @shift
  end

  def assign
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    @assignable_users_items = @firm.firm_permissions.where(:status => true).paginate(page: params[:page])
  end

  def remove_worker
    @shift = Shift.find(params[:id])
    @worker = User.find(@shift.fk_user_worker)
    @shift.fk_user_worker = nil
    if @shift.save
      flash[:success] = "You cleared this shift, user has been informed"
      ShiftMailer.cancelled_shift(@worker,@shift).deliver
      redirect_to @shift
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
      ShiftMailer.assigned_shift(@shiftworker,@shift).deliver
      flash[:success] = "Shift was assigned to #{@shiftworker.name}"
      redirect_to @shift
    end
  end

  def edit
    @shift = Shift.find(params[:id])
  end

  def update
    @shift = Shift.find(params[:id])
    if @shift.update_attributes(params[:shift])
      flash[:success] = "Shift information was updated"
      redirect_to @shift
    else
      flash[:error] = "Something went wrong when updating the shift"
      render 'edit'
    end
  end

  def clone
    @shift = Shift.find(params[:id])
    @shift2 = @shift.dup
    newshiftclone(@shift2)
  end

  def newshiftclone(shift)
    @shift = shift
    @firm = Firm.find(current_user.business_id)
    render 'newshiftclone'
  end


  def series
    @shift = Shift.find(params[:id])
    @shift_series_items = Shift.where('series_id = ?',@shift.series_id).order(:id)
  end

  def dais
    # (delete all in series)
    @shift = Shift.find(params[:id])
    @shifts_series = Shift.where('series_id = ?',@shift.series_id)
    @shifts_series.each do |sshift| 
        if !sshift.fk_user_worker.nil? 
          @suser = User.find(sshift.fk_user_worker)
          ShiftMailer.cancelled_shift(@suser,sshift).deliver
        end
        sshift.destroy
      end
    flash[:success] = "You deleted all shifts in series #{@shift.series_id}. Any people who were assigned 
        shifts in this series have been informed."
    redirect_to shifts_firm_path(current_user.business_id)
  end

  def dsis
    @shift = Shift.find(params[:id])
    @shifts_array = params[:shifts]
    if @shifts_array.empty?
      flash[:error] = "Please select some shifts first"
      redirect_to series_shift_path(@shift)
    else
      @shifts_array.split(',').each do |shift|
        @sshift = Shift.find(shift)
        if !@sshift.fk_user_worker.nil?
          @suser = User.find(@sshift.fk_user_worker)
          ShiftMailer.cancelled_shift(@suser,@sshift).deliver
        end
        @sshift.destroy
      end
      if Shift.where('id = ?',params[:id]).any?
        flash[:success] = "You deleted #{@shifts_array.split(',').length} shifts from this series. Any people who were assigned 
        shifts in this series have been informed."
        redirect_to series_shift_path(params[:id])
      else
        flash[:success] = "You deleted #{@shifts_array.split(',').length} shift(s). Any people who were assigned 
        shifts in this series have been informed."
        redirect_to shifts_firm_path(current_user.business_id)
      end
    end
  end

  def rais
    @shift = Shift.find(params[:id])
    @shifts_series = Shift.where('series_id = ?',@shift.series_id)
    @shifts_series.each do |rshift|
      if !rshift.fk_user_worker.nil?
          @suser = User.find(rshift.fk_user_worker)
          ShiftMailer.cancelled_shift(@suser,rshift).deliver
        end
      rshift.update_attributes(fk_user_worker: nil)
    end
    flash[:success] = "You removed worker from all shifts in the series"
    redirect_to series_shift_path(@shift)
  end

  def rsis
    @shift = Shift.find(params[:id])
    @shifts_array = params[:shifts]
    if @shifts_array.empty?
      flash[:error] = "Please select some shifts first"
      redirect_to series_shift_path(@shift)
    else
      @shifts_array.split(',').each do |rshift|
        @sshift = Shift.find(rshift)
        if !@sshift.fk_user_worker.nil?
          @suser = User.find(@sshift.fk_user_worker)
          ShiftMailer.cancelled_shift(@suser,@sshift).deliver
        end
        @sshift.update_attributes(fk_user_worker: nil)
      end
      flash[:success] = "You removed worker from #{@shifts_array.split(',').length} shifts"
      redirect_to series_shift_path(@shift)
    end
  end

  def ais
    @shift = Shift.find(params[:id])
    if (params[:all] == "false" && params[:shifts] == "" )
      flash[:error] = "Could not assign shift(s) - you did not select any shifts"
      redirect_to series_shift_path(@shift)
    else
      @firm = Firm.find(@shift.firm_id)
      @assignable_users_series_items = @firm.firm_permissions.where(status: true).paginate(page: params[:page])
    end
  end

  def ais_to_worker
    @shift = Shift.find(params[:id])
    @firm = Firm.find(@shift.firm_id)
    if params[:all] == "true"
      @shifts_array = Shift.where('series_id = ?',@shift.series_id)
    else
      @shifts_array = Shift.where('id in (?)',params[:shifts].split(','))
    end
    @worker = User.find(params[:workerid])
    @shifts_array.each do |ashift|
      if !ashift.fk_user_worker.nil?
          @suser = User.find(ashift.fk_user_worker)
          ShiftMailer.cancelled_shift(@suser,ashift).deliver
        end
      ashift.update_attributes(:fk_user_worker => @worker.id)
    end
    flash[:success] = "You assigned shifts in this series to #{@worker.name}"
    redirect_to series_shift_path(@shift)
  end

  private

  def correct_user
    @shift = Shift.find_by_id(params[:id])
    redirect_to root_url unless current_user.firm_permissions.where(firm_id: @shift.firm_id).where(status: true).any?
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
  
  def create_repeat_shifts(shift)
    @days_array = [shift.r_su, shift.r_mo, shift.r_tu, shift.r_we, shift.r_th, shift.r_fr,shift.r_sa]
    @repeat_count = 1
    @repeat_date = shift.start_datetime.to_date + 1.day
      until (@repeat_date > shift.repeat_until || @repeat_count > 50 )
        if @days_array[@repeat_date.wday] == true
          @shiftx = shift.dup
          @shiftx.start_datetime += @repeat_count.days
          @shiftx.save
        end
        @repeat_count += 1
        @repeat_date += 1.day
      end
  end
end