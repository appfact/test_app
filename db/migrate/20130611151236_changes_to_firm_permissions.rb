class ChangesToFirmPermissions < ActiveRecord::Migration
  def change
  	add_index :firm_permissions, :user_id , unique: false
  	add_index :firm_permissions, :firm_id , unique: false
  	add_index :firm_permissions, :type , unique: false
  	add_index :firm_permissions, [:user_id, :firm_id, :type] , unique: true
  end
end