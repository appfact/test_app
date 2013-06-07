class CreateShiftRequests < ActiveRecord::Migration
  def change
    create_table :shift_requests do |t|
      t.integer :shift_id
      t.integer :worker_id
      t.integer :manager_id
      t.boolean :worker_status
      t.boolean :manager_status

      t.timestamps
    end
  end
end
