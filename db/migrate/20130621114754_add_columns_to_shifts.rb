class AddColumnsToShifts < ActiveRecord::Migration
   def change
  	add_column :shifts, :series_id, :integer
  	add_column :shifts, :r_mo, :boolean
  	add_column :shifts, :r_tu, :boolean
  	add_column :shifts, :r_we, :boolean
  	add_column :shifts, :r_th, :boolean
  	add_column :shifts, :r_fr, :boolean
  	add_column :shifts, :r_sa, :boolean
  	add_column :shifts, :r_su, :boolean
  	add_column :shifts, :repeat_type, :integer
  	add_column :shifts, :repeat_until, :date
  end
end
