class Firm < ActiveRecord::Base
  attr_accessible :branch, :name, :sign_up_code

  has_many :firm_permissions, dependent: :destroy
  has_many :shifts, dependent: :destroy

  validates :name, presence: true, length: {maximum: 50}
  validates :branch, length: {maximum: 50}
  validates :sign_up_code, length: {maximum: 30}, uniqueness: true, presence: true

  def network_users
  	@network_users_array = self.firm_permissions.find_all_by_status(true)
  end


  

end
