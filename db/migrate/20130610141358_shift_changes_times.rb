class ShiftChangesTimes < ActiveRecord::Migration
  def change
  	remove_column :shifts, :start_time
  	remove_column :shifts, :start_date
  	add_column :shifts, :start_time, :datetime
  	add_column :shifts, :start_date, :datetime
  end
end
