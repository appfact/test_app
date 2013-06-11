class CreateFirmPermissions < ActiveRecord::Migration
  def change
    create_table :firm_permissions do |t|
      t.integer :firm_id
      t.integer :user_id
      t.boolean :status
      t.integer :type
      t.boolean :admin

      t.timestamps
    end
  end
end
