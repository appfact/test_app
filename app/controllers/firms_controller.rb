class FirmsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:new, :create, :update, :network, :rufn]
  before_filter :user_can_view_firm?, only: [:show, :network, :rufn]
  before_filter :cannot_rufn_self, only: :rufn
  #check that this before filter doesn't interfere with correct display of network page

  def new
  	@firm = Firm.new
  end

def create
    @firm = Firm.new(params[:firm])
    if @firm.save
      auth_admin_user!(@firm)
      flash[:success] = "You created a new business"
      redirect_to @firm
          else
    render new_firm_path
    end
  end

  def update
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

  def rufn
    @firm = Firm.find(params[:id])
    @firm.firm_permissions.find_by_user_id(params[:userid]).toggle!(:status)
    @user = User.find(params[:userid])
    flash[:success] = "You have removed #{@user.name} from your network"
    redirect_to network_firm_path(@firm)
  end

  def shifts
    @firm = Firm.find(params[:id])
    @open_shifts = @firm.shifts.find_all_by_fk_user_worker(nil)
    @open_shifts_items = @firm.open_shifts2.paginate(page: params[:page])
  end

  def shiftrequests
    @firm = Firm.find(params[:id])
    @shift_requests_items = @firm.shift_requests.find(:all, 
          conditions: ["worker_status is ? AND manager_status is ? 
                         AND start_datetime > ?", true, nil, Time.now.to_datetime], order: [:shift_id, :created_at])
  end

  def newshift
    @firm = Firm.find(params[:id])
    @shift = Shift.new
    @shift.duration_mins = Time.now.beginning_of_day
  end

  private

  def admin_user
  	if !current_user.admin?
  		flash[:error] = "Only admin users can do that"
  		redirect_to @firm
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
    unless !@firm.firm_permissions.find_by_user_id_and_status(current_user.id,true).nil?
      flash[:error] = "You do not have permission to do that"
      redirect_to network_firm_path(@firm)
    end
  end

end
