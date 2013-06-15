class AddAllocationTypeToShifts < ActiveRecord::Migration
  def change
  	add_column :shifts, :allocation_type, :integer
  end
end
