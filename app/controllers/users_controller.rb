class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :switch_from_user_to_admin, :shifts, :offers, :requests]
  before_filter :correct_user,   only: [:edit, :update]
  # correct_user private method ensures users can only edit their own info
  before_filter :admin_user,     only: [:destroy, :invite, :switch_business_account]
  # might need to change this to admin user OR shift manager can do invite
  before_filter :admin_user_cannot_delete_self, only: :destroy
  before_filter :not_signed_in, only: [:new, :newuser]
#  before_filter :business_id_misassign, only: :update
  before_filter :check_if_business_account, only: [:create]
  before_filter :can_view_user_profile, only: [:show]
  before_filter :is_superadmin?, only: [:index]



  def show
    @user = User.find(params[:id])
    @user_networks = @user.firm_permissions.where(:status => true)
  end

  def new
    @user = User.new
  end

  def newuser
    @user = User.new
  end

  def shifts
    @user = current_user
    @feed_items = current_user.feed.paginate(page: params[:page])
    @feed_items_past = current_user.feed2
    @feed_items_all = current_user.feed3
    @open_shift_items = current_user.open_shifts.paginate(page: params[:page])
    @availableshifts = available_shifts
    @offers_items = available_shifts_offers
    @requests_items = available_shifts_requests
  end

  def pastshifts
    @feed_items_upcoming = current_user.feed
    @feed_items = current_user.feed2.paginate(page: params[:page])
    @feed_items_all = current_user.feed3
    @offers_items = available_shifts_offers
    @requests_items = available_shifts_requests
  end

  def allshifts
    @feed_items_upcoming = current_user.feed
    @feed_items_past = current_user.feed2
    @feed_items = current_user.feed3.paginate(page: params[:page])
    @offers_items = available_shifts_offers
    @requests_items = available_shifts_requests
  end

  def availableshifts
    @availableshifts = available_shifts
    @offers_items = available_shifts_offers
    @requests_items = available_shifts_requests
    @feed_items = current_user.feed
  end

  def offers
    @offers_items = available_shifts_offers
    @requests_items = available_shifts_requests
    @feed_items = current_user.feed    
  end

  def requests
    @requests_items = available_shifts_requests
    @offers_items = available_shifts_offers
    @feed_items = current_user.feed.paginate(page: params[:page])
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
    if params[:user][:sign_up_stage] == "1"
      @firm = Firm.find(current_user.business_id.to_i)
      unless User.find_by_email(params[:user][:email]).nil?
        # unless the user doesn't exist, then permission an existing user
        @addeduser = User.find_by_email(params[:user][:email])
        if @addeduser.firm_permissions.find_by_firm_id(current_user.business_id).nil?
          auth_added_user!(@addeduser.id, current_user.business_id)
          # note that auth added user already contains the mailer inform_user_added_to_network
          flash[:success] = "User was added to your network"
          redirect_to '/invite'
          return
        end
        if !@firm.firm_permissions.find_by_user_id_and_status(@addeduser.id,false).nil?
          @firm.firm_permissions.find_by_user_id_and_status(@addeduser.id,false).toggle!(:status)
          UserMailer.inform_user_added_to_network(@addeduser,current_user).deliver
        end
        flash[:success] = "User is part of your network"
        redirect_to '/invite'
        return
      end
          # the user doesn't exist so we're going to create a new user on behalf of the admin
      @user = User.new(params[:user])
      if @user.save
        auth_created_user!(@user.id, current_user.business_id)
        flash[:success] = "new user made"
        redirect_to '/invite'
      else
        flash[:error] = "error - user was not created"
        render '/invite'
      end
      # create_automatic_user(@userz)
    else
      @user = User.new(params[:user])
      if @user.save
        adminify(@user,@firmid)
        sign_in @user
          if @user.admin?
            UserMailer.welcome_admin(@user).deliver
          redirect_to '/firms/new'
          return
        else
          auth_normal_user!(@firmid)
          flash[:success] = "Welcome to ShiftCloud! Get started by viewing your shifts or finding an available shift."
          redirect_to '/home'
          return
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

  def invite
  end

  def user_remove_network
    @user = User.find(params[:id])
    @permission = @user.firm_permissions.find(params[:permissionid])
    @permission.toggle!(:status)
    @user.shift_requests.all.each do |request|
      request.destroy
    end
    redirect_to @user
  end

  def switch_business_account
    unless current_user.firm_permissions.where(status: true, admin: true).where('firm_id = ?', 
              params[:businessid]).nil?
       @firm = Firm.find(params[:businessid])
       if current_user.update_attribute(:business_id, params[:businessid])
          flash[:success] = "You switched account to #{@firm.name} #{@firm.branch}"
          redirect_to @firm
        else
          flash[:error] = "could not change account - please try again"
          redirect_to @firm
        end
     else
      redirect_to current_user
    end
  end

  def switch_from_user_to_admin
    @user = current_user
    if @user.firm_permissions.where(:status => true).where('firm_id = ? AND 
           admin = ?',params[:businessid],true).any?
       @user.update_attributes(business_id: params[:businessid])
       @user.toggle!(:admin)
       @firm = Firm.find(params[:businessid])
       flash[:success] = "You switched account to #{@firm.name} #{@firm.branch}"
       redirect_to '/home'
     else
      redirect_to root_path
    end
  end

  def switch_to_non_admin
    if current_user.admin?
      @user = current_user
      @user.toggle!(:admin)
    end
    redirect_to '/home'
  end

  def userholiday
    # the variables are in the users helper
  end

  def userholidayrequests
    @holidays_requests = Shift.where(fk_user_worker: current_user.id, status: nil).
        where('end_datetime > ? AND allocation_type = ?', Time.now.to_datetime, 10)
  end

  def userpastholidays
  end

  def userunavailable
    # variables in the users helper
  end

  def cancelunavailable
    @shift = Shift.find(params[:unavailableid]) rescue nil
    if @shift.nil?
      flash[:error] = "There was a problem, please try again"
      redirect_to userunavailable_user_path(current_user)
    elsif (@shift.fk_user_worker == current_user.id && @shift.allocation_type == 12)
      @shift.destroy
      flash[:success] = "You cancelled this unavailable time"
      redirect_to userunavailable_user_path(current_user)
    else
      flash[:error] = "There was a problem, please try again"
      redirect_to userunavailable_user_path(current_user)
    end
  end

    def cancelholidayrequest
    @shift = Shift.find(params[:requestid])
    if @shift.nil?
      flash[:error] = "There was a problem, please try again"
      redirect_to userholidayrequests_user_path(current_user)
    elsif (@shift.fk_user_worker == current_user.id && @shift.allocation_type == 10 && @shift.status == nil)
      @shift.destroy
      flash[:success] = "You cancelled your holiday request"
      redirect_to userholidayrequests_user_path(current_user)
    else
      flash[:error] = "There was a problem, please try again"
      redirect_to userholidayrequests_user_path(current_user)
    end
  end

  def newholiday
    @shift = Shift.new
  end

  def newunavailable
    @shift = Shift.new
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

  def auth_created_user!(userid, firmid)
    @firmx = Firm.find(firmid)
    @userx = User.find(userid)
    @password = ('a'..'z').to_a.shuffle[0..7].join
    @userx.update_attributes(password: @password, password_confirmation: @password)
    @permission = @firmx.firm_permissions.create!(user_id: userid, kind: 1)
    @permission.toggle!(:status)
    UserMailer.send_new_created_user_password(@userx,@password,@firmx).deliver
    @password = ""
  end

  def auth_added_user!(userid, firmid)
    @firmx = Firm.find(firmid)
    @userx = User.find(userid)
    @permission = @firmx.firm_permissions.create!(user_id: userid, kind: 1)
    @permission.toggle!(:status)
    UserMailer.inform_user_added_to_network(@userx,current_user).deliver
  end

  def available_shifts
    @permissionsarray = []
    @userspermissions = current_user.firm_permissions.where(:status => true)
    #move these variables to helpers
    @userspermissions.each do |permission|
      @permissionsarray.push(permission.firm_id)
    end
    return Shift.where("firm_id in (?) AND fk_user_worker is ? 
                  AND start_datetime > ? AND allocation_type in (1,2)", @permissionsarray, nil, Time.now.to_datetime)
                  .order(:start_datetime)
  end

  def available_shifts_offers
    @user = current_user
    @offersarray = []
    @useroffers = @user.shift_requests.where(worker_status: nil, manager_status: true)
    @useroffers.each do |offer|
      @offersarray.push(offer.shift_id)
    end
    return Shift.where('id in (?) AND fk_user_worker is ?', @offersarray, nil)
  end

  def available_shifts_requests
    @user = current_user
    @requestsarray = []
    @userrequests = @user.shift_requests.where(worker_status: true, manager_status: nil)
    @userrequests.each do |request|
      @requestsarray.push(request.shift_id)
    end
    return Shift.where('id in (?) AND fk_user_worker is ?', @requestsarray, nil)
  end

  def can_view_user_profile
    @userprofile = User.find(params[:id])
    if current_user != @userprofile
      if !current_user.admin? || @userprofile.firm_permissions.where(status: true).
                  where('firm_id = ?', current_user.business_id.to_i).length == 0
          flash[:error] = "You don't have permission to view that page"
          redirect_to current_user
        
      end
    end
  end

  def is_superadmin?
    unless current_user.superadmin?
      flash[:error] = "The page was not found"
      redirect_to root_path
    end
  end
  
end


  #  def business_id_misassign
# fill this in to stop people misassigning businesses?
# might be unnecessary if using relationships instead
 #   end



