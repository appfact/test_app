class EditShifts2 < ActiveRecord::Migration
  def change
  	add_column :shifts, :duration_mins, :integer
  	add_column :shifts, :start_date, :date
  	remove_index :shifts, [:end_time]
  	remove_index :shifts, [:end_time, :user_id]
  	remove_column :shifts, [:end_time] 
  end
end