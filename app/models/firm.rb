class Firm < ActiveRecord::Base
  attr_accessible :branch, :name, :sign_up_code

  has_many :firm_permissions, dependent: :destroy
  has_many :shifts, dependent: :destroy
  has_many :shift_requests, through: :shifts

  validates :name, presence: true, length: {maximum: 50}
  validates :branch, length: {maximum: 50}
  validates :sign_up_code, length: {maximum: 30}, uniqueness: true, presence: true

  def network_users
  	return self.firm_permissions.where(:status => true)
  end

  def open_shifts2
    Shift.open_shifts_logic2(self)
  end

  def shift_requests2(workerid)
  	shift_requests.where("worker_id = ?", workerid)
  end


  

end
