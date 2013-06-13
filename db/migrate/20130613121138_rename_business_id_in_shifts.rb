class RenameBusinessIdInShifts < ActiveRecord::Migration
  def change
  	rename_column :shifts, :business_id, :firm_id
  end
end
