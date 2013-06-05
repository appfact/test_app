class ShiftsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

 def create
    @shift = current_user.shifts.build(params[:shift])
    if @shift.save
      flash[:success] = "Shift created!"
      redirect_to '/shifts'
    else
      @feed_items = []
      flash[:error] = "Shift could not be created - please try again"
      render '/shifts'
    end
 end

  def destroy
    @shift.destroy
    redirect_to '/shifts'
  end

  private

  def correct_user
    @shift = current_user.shifts.find_by_id(params[:id])
    redirect_to root_url if @shift.nil?
  end
end