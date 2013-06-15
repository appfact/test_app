class StaticPagesController < ApplicationController
  before_filter :signed_in_user,  only: [:shifts, :newshift]
  before_filter :admin_user,     only: :newshift


  def home
  end

  def contact
  end



  def newshift
  	@user = current_user
  	@shift = current_user.shifts.build if signed_in?
  end

  private

  def admin_user
  	unless current_user.admin?
  		flash[:error] = "You must be admin to create shifts"
  		redirect_to '/shifts'
  	end
  end


end
