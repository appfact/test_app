class Shift < ActiveRecord::Base
  attr_accessible :description, :fk_user_worker, 
  			:role, :start_datetime, :status, :end_datetime, :duration_mins
  
  belongs_to :user
  has_many :shift_requests, dependent: :destroy
  has_many :requests_for_this_shift, through: :shift_requests, source: :shift

  before_save :convert_times

  validates :user_id, presence: true
  validates :role, presence: true, length: {maximum:50}
  validates_numericality_of :duration_mins, :only_integer => true, :message => "can only be whole number."

  def self.from_feed_logic(userx)
  	where("business_id = ?", userx.business_id)
  end
 
  def self.open_shifts_logic(usery)
  	where("business_id = ? AND fk_user_worker is null", usery.business_id) 
  end

  def available_users
    User.available_users_logic(self)
  end

  def requested?(workerx)
    self.shift_requests.find_by_worker_id(workerx.id)
  end

  def request!(workerx)
    self.shift_requests.create!(worker_id: workerx, worker_status: true)
  end
  #note the self here is optional

  def offer!(workerx,managerx)
    self.shift_requests.create!(worker_id: workerx, manager_id: managerx, manager_status: true)
  end


  def unfollow!(workerx)
    shift_requests.find_by_worker_id(workerx.id).destroy
  end

  private

  def convert_times
    self.end_datetime = self.start_datetime + (self.duration_mins*60)
  end
end
