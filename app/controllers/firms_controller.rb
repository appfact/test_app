class FirmsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:new, :newshift, :create, :update, :network, :rufn, :makeadmin, :removeadmin]
  before_filter :user_can_view_firm?, only: [:show, :network, :rufn]
  before_filter :cannot_rufn_self, only: :rufn
  before_filter :rufn_correct_firm, only: [:rufn, :makeadmin, :removeadmin]
  before_filter :newuser, only: [:new, :create]
  #check that this before filter doesn't interfere with correct display of network page

  def new
  	@firm = Firm.new
  end

  def edit
    @firm = Firm.find(params[:id])
  end

  def update
    @firm = Firm.find(params[:id])
    if @firm.update_attributes(params[:firm])
      flash[:success] = "Company information succesfully updated"
      redirect_to @firm
    else
      flash[:error] = "Something went wrong updating company information"
      render 'edit'
    end
  end

def create
    @firm = Firm.new(params[:firm])
    if @firm.save
      auth_admin_user!(@firm)
      flash[:success] = "You succesfully created a new account for #{@firm.name} #{@firm.branch}!"
      redirect_to '/home'
    else
      render new_firm_path
    end
  end

  def show
    unless user_can_view_firm?
      flash[:error] = "You don't have permission to view that page"
      redirect_back_or root_url
    end
  end

  def network
    @firm = Firm.find(params[:id])
    @network_users = @firm.network_users
    render 'network'
  end

  def permissions
    @firm = Firm.find(params[:id])
    @network_permissions = @firm.network_users
  end

  def stats
    @firm = Firm.find(params[:id])
    @stats = @firm.network_users
  end

  def rufn
    @firm = Firm.find(params[:id])
    @firm.firm_permissions.find_by_user_id(params[:userid]).toggle!(:status)
    @user = User.find(params[:userid])
    flash[:success] = "You have removed #{@user.name} from your network"
    @firm.shift_requests.where(worker_id: @user.id).each do |request|
      request.destroy
    end
    redirect_to permissions_firm_path(@firm)
  end

  def makeadmin
    @firm = Firm.find(params[:id])
    @firm.firm_permissions.find_by_user_id(params[:userid]).toggle!(:admin)
    @user = User.find(params[:userid])
    flash[:success] = "You have made #{@user.name} an administrator."
    redirect_to permissions_firm_path(@firm)
  end

  def removeadmin
    @firm = Firm.find(params[:id])
    @firm.firm_permissions.find_by_user_id(params[:userid]).toggle!(:admin)
    @user = User.find(params[:userid])
    flash[:success] = "You have removed admin privileges from #{@user.name}."
    redirect_to permissions_firm_path(@firm)
  end

  def shifts
    @firm = Firm.find(params[:id])
    @open_shifts = @firm.shifts.find_all_by_fk_user_worker(nil)
    @open_shifts_items = @firm.open_shifts2.paginate(page: params[:page])
    @shift_requests_items = @firm.shift_requests
                                .where(:worker_status => true, :manager_status => nil) 
                                .where('end_datetime > ? AND fk_user_worker is ?', Time.now.to_datetime, nil)
                                .order(:shift_id, :created_at)
  end

  def shiftrequests
    @firm = Firm.find(params[:id])
    @shift_requests_items = @firm.shift_requests
                                .where(:worker_status => true, :manager_status => nil) 
                                .where('end_datetime > ? AND fk_user_worker is ?', Time.now.to_datetime, nil)
                                .order(:shift_id, :start_datetime).paginate(page: params[:page])
  end


  def schedules
    @schedules = true
    @firm = Firm.find(params[:id])
    params[:sdate] == nil ? @s_date = Date.today : @s_date = Date.parse(params[:sdate])
    @s_hash_items = @firm.shifts.where('(start_datetime > ? AND start_datetime < ?) OR 
      (end_datetime > ? AND end_datetime < ?)', 
              @s_date.beginning_of_day, @s_date.end_of_day, 
              @s_date.beginning_of_day, @s_date.end_of_day).paginate(page: params[:page])
              .order(:role, :start_datetime)
    @s_hash_items2 = @firm.shifts.where('(start_datetime > ? AND start_datetime < ?) OR 
      (end_datetime > ? AND end_datetime < ?)', 
              @s_date.beginning_of_day, @s_date.end_of_day, 
              @s_date.beginning_of_day, @s_date.end_of_day).order(:start_datetime).first
    @s_hash_items3 = @firm.shifts.where('(start_datetime > ? AND start_datetime < ?) OR 
      (end_datetime > ? AND end_datetime < ?)', 
              @s_date.beginning_of_day, @s_date.end_of_day, 
              @s_date.beginning_of_day, @s_date.end_of_day).order(:end_datetime).last
    if @s_hash_items.any?
      @s_start_hour = [@s_hash_items2.start_datetime, @s_date.beginning_of_day].sort.last.seconds_since_midnight.to_i
      @s_start_hour % 3600 == 0 ? @s_start_hour : @s_start_hour -= (@s_start_hour % 3600)
      @s_end_hour = [@s_hash_items3.end_datetime, @s_date.end_of_day].sort.first.seconds_since_midnight.to_i
      @s_end_hour % 3600 == 0 ? @s_end_hour : @s_end_hour += (3600 - (@s_end_hour % 3600))
      @s_day_length = @s_end_hour.to_f - @s_start_hour.to_f
    end                                     
  end

  def hourscalculator
    @firm = Firm.find(params[:id])
    params[:from].nil? ? @from = @firm.created_at : @from = Date.parse(params[:from])
    params[:to].nil? ? @to = Time.now.end_of_day : @to = Date.parse(params[:to])
    @employees_hours_items = @firm.shifts.where('start_datetime > ? AND start_datetime < ? AND fk_user_worker is not ?',
          @from.beginning_of_day,@to.end_of_day, nil).group(:fk_user_worker)
  end

  private

  def admin_user
  	if !current_user.admin?
  		flash[:error] = "Only admin users can do that"
  		redirect_to 'shifts'
  	end
  end

  def auth_admin_user!(firm)
    @permission = firm.firm_permissions.create!(user_id: current_user.id, kind: 2)
    @permission.toggle!(:status)
    @permission.toggle!(:admin)
    current_user.update_attribute(:business_id, firm.id)
  end

  def user_can_view_firm?
    @firmy = Firm.find(params[:id])
    if @firmy.firm_permissions.find_by_user_id_and_status(current_user.id,true)
      true
    else
      flash[:error] = "You cannot view this page"
      redirect_to root_url
    end
  end

  def cannot_rufn_self
    @firm = Firm.find(params[:id])
    if params[:userid].to_i == current_user.id
      flash[:error] = "You cannot remove yourself from the network"
      redirect_to network_firm_path(@firm)
    end
  end

  def rufn_correct_firm
    @firm = Firm.find(params[:id])
    if @firm.firm_permissions.find_by_user_id_and_status(current_user.id,true).nil?
      flash[:error] = "You do not have permission to do that"
      redirect_to network_firm_path(@firm)
    end
  end

  def newuser
    unless current_user.business_id == "ASSA{}{}{345345[]]]"
      redirect_to root_url
    end
  end

end
