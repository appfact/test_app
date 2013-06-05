class StaticPagesController < ApplicationController
  def home
  end

  def contact
  end

  def shifts
  	@user = current_user
  	@shifts = @user.shifts.paginate(page: params[:page])
  	@feed_items = @user.feed.paginate(page: params[:page])
  end

  def newshift
  	@user = current_user
  	@shift = current_user.shifts.build if signed_in?
  end

end
