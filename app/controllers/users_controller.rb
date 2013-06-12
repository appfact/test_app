class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  # correct_user private method ensures users can only edit their own info
  before_filter :admin_user,     only: :destroy
  before_filter :admin_user_cannot_delete_self, only: :destroy
  before_filter :not_signed_in, only: [:new, :newuser]
#  before_filter :business_id_misassign, only: :update
  before_filter :check_if_business_account, only: [:create]


  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def newuser
    @user = User.new
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def create
    if params[:user][:sign_up_stage] == 1
      create_automatic_user(params[:user])
    else
      @user = User.new(params[:user])
      if @user.save
        adminify(@user,@firmid)
        sign_in @user
          if @user.admin?
          redirect_to '/firms/new'
        else
          auth_normal_user!(@firmid)
          flash[:success] = "User signed up ok - business id = #{@user.business_id}"
          redirect_to users_url
        end
      else
        if @firmid != "ASSA{}{}{345345[]]]"
          render 'newuser'
        else
          render 'new'
        end
      end
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def admin_user_cannot_delete_self
      if User.find(params[:id]) == current_user
        flash[:error] = "You cannot delete yourself"
        redirect_to root_path
      end
    end

    def not_signed_in
      if signed_in?
        flash[:error] = "You are already signed up"
        redirect_to root_path
      end
    end

    def adminify(user,businessid)
      if businessid == "ASSA{}{}{345345[]]]"
        user.toggle!(:admin)
        user.business_id = 0
      end
    end

    def check_if_business_account
      @firmid = params[:user][:business_id] || ""
      if @firmid != "ASSA{}{}{345345[]]]"
        @firmid = Firm.find_by_sign_up_code(params[:user][:business_id])
        if @firmid == nil
          @firmid == ""
          flash[:error] = "The sign up code was not recognised"
          redirect_to '/signupuser'
          # can add params to redirect so something like 'signupuser? + params[:user] ???'
        end
      end
    end

  def auth_normal_user!(firmid)
    @firmx = Firm.find(firmid)
    @permission = @firmx.firm_permissions.create!(user_id: current_user.id, kind: 1)
    @permission.toggle!(:status)
  end


  #  def business_id_misassign
# fill this in to stop people misassigning businesses?
# might be unnecessary if using relationships instead
 #   end


end
