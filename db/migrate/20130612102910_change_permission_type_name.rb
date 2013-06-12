class ChangePermissionTypeName < ActiveRecord::Migration
  def change
  	remove_index :firm_permissions, [:user_id, :firm_id, :type]
  	rename_column :firm_permissions, :type, :kind
  	add_index :firm_permissions, [:user_id, :firm_id, :kind]
  end
end
