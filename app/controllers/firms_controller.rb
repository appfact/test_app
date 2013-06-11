class FirmsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user, only: [:new, :create, :update]

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
    @permission = @firmx.firm_permissions.create!(user_id: current_user.id, type: 2)
    @permission.toggle!(:status)
    @permission.toggle!(:admin)
  end

end
