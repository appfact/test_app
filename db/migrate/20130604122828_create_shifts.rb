class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.integer :user_id
      t.datetime :start_time
      t.datetime :end_time
      t.string :role
      t.text :description
      t.integer :fk_user_worker
      t.string :status

      t.timestamps
    end
     add_index :shifts, [:user_id]
     add_index :shifts, [:fk_user_worker] 
     add_index :shifts, [:start_time]
     add_index :shifts, [:end_time]
     add_index :shifts, [:status]
     add_index :shifts, [:start_time, :user_id]
     add_index :shifts, [:end_time, :user_id]
  end
end
