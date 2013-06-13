class DurationMinsTimeField < ActiveRecord::Migration
  def change
  	change_column :shifts, :duration_mins, :time
  end
end
