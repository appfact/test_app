class EditShifts < ActiveRecord::Migration
  def change
  	change_column :shifts, :start_time, :time
  end
end