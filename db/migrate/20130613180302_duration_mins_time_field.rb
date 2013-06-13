class DurationMinsTimeField < ActiveRecord::Migration
  def change
  	remove_column :shifts, :duration_mins 
  	add_column :shifts, :duration_mins, :time
  end
end
