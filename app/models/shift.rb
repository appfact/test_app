class Shift < ActiveRecord::Base
  attr_accessible :description, :fk_user_worker, 
  			:role, :start_time, :status, :start_date, :duration_mins
  belongs_to :user
  has_many :shift_requests, dependent: :destroy
  has_many :requests_for_this_shift, through: :shift_requests, source: :shift

  validates :user_id, presence: true
  validates :role, presence: true, length: {maximum:50}
  validates_numericality_of :duration_mins, :only_integer => true, :message => "can only be whole number."

  def self.from_feed_logic(userx)
  	where("business_id = ?", userx.business_id)
  end
 
  def self.open_shifts_logic(usery)
  	where("business_id = ? AND fk_user_worker is null", usery.business_id) 
  end

  def requested?(workerx)
    self.shift_requests.find_by_worker_id(workerx.id)
  end

  def request!(workerx)
    self.shift_requests.create!(worker_id: workerx)
  end
  #note the self here is optional

  def unfollow!(workerx)
    shift_requests.find_by_worker_id(workerx.id).destroy
  end
end
