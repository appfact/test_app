class ShiftChangesTimes < ActiveRecord::Migration
  def change
  	change_column :shifts, :start_time, :datetime
  	change_column :shifts, :start_date, :datetime
  end
end
