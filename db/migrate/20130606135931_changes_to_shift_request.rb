class ChangesToShiftRequest < ActiveRecord::Migration
  def change
  	add_index :shift_requests, :shift_id, unique: false
  	add_index :shift_requests, :worker_id, unique: false
  	add_index :shift_requests, :manager_id, unique: false
  	add_index :shift_requests, [:worker_status, :manager_status], unique: false
  	add_index :shift_requests, [:shift_id, :worker_id], unique: true
  end
end
