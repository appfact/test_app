class AddBusIdToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :business_id, :integer
  end
end
