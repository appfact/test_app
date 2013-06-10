class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  # correct_user private method ensures users can only edit their own info
  before_filter :admin_user,     only: :destroy
  before_filter :admin_user_cannot_delete_self, only: :destroy
  before_filter :not_signed_in, only: [:new, :newuser]


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
    #need to add something here to check business id
    @user = User.new(params[:user])
    if @user.save
      adminify(@user,0)
      sign_in @user
      if !@user.admin?
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        redirect_to '/firms/new'
      end
      # note - this redirect to @user should be changed.
      # because we want to do the next signup step
    else
      render 'new'
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
      if businessid == 0
        user.toggle!(:admin)
      end
    end


end
