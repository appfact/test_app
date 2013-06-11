class ChangeShiftsBusinessId < ActiveRecord::Migration
  def change
  	change_column :users, :business_id, :string
  end
end
