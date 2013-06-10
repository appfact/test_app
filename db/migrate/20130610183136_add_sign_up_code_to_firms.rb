class AddSignUpCodeToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :sign_up_code, :string
  end
end
