class ShiftChangesDataFormats < ActiveRecord::Migration
  def change
  	rename_column :shifts, :start_date, :end_datetime
  	rename_column :shifts, :start_time, :start_datetime
  end
end
