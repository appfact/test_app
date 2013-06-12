class FirmsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:new, :create, :update]
  before_filter :user_can_view_firm?, only: [:show, :network]
  #check that this before filter doesn't interfere with correct display of network page

  def new
  	@firm = Firm.new
  end

def create
    @firm = Firm.new(params[:firm])
    if @firm.save
      auth_admin_user!(@firm.id)
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

  private

  def admin_user
  	if !current_user.admin?
  		flash[:error] = "Only admin users can do that"
  		redirect_to @firm
  	end
  end

  def auth_admin_user!(firmid)
    @firmx = Firm.find(firmid)
    @permission = @firmx.firm_permissions.create!(user_id: current_user.id, kind: 2)
    @permission.toggle!(:status)
    @permission.toggle!(:admin)
    current_user.business_id = firmid
  end

  def user_can_view_firm?
    @firmy = Firm.find(params[:id])
    if @firmy.firm_permissions.find_by_user_id_and_status(current_user.id,true)
      true
    else
      false
    end
  end


end
