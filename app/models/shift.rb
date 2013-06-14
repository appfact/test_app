class Shift < ActiveRecord::Base
  attr_accessible :description, :fk_user_worker, 
  			:role, :start_datetime, :status, :end_datetime, :duration_mins
  
  belongs_to :firm
  has_many :shift_requests, dependent: :destroy
  has_many :requests_for_this_shift, through: :shift_requests, source: :shift

  before_save :convert_times

  validates :user_id, presence: true
  validates :role, presence: true, length: {maximum:50}

  def self.from_feed_logic(userx)
    where("fk_user_worker = ? AND end_datetime > ?", userx.id, Time.now.to_datetime).order(:start_datetime)
  # took out line that doesn't work
  # where("fk_user_worker = ?", userx.id)
  end

  def self.from_feed_logic_past(userx)
    where("fk_user_worker = ? AND end_datetime < ?", userx.id, Time.now.to_datetime).order(:start_datetime)
  end

  def self.from_feed_logic_all(userx)
    where("fk_user_worker = ?", userx.id).order(:start_datetime)
  end
 
  def self.open_shifts_logic(usery)
  	where("firm_id = ? AND fk_user_worker is null", usery.business_id) 
  end

  def self.open_shifts_logic2(firmy)
    where("firm_id = ? AND fk_user_worker is null", firmy.id).order(:start_datetime)
    #) ORDER BY start_datetime  
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

  def futureshiftsforfirm(firm)
    where("firm_id = ? AND start_datetime > ? AND fk_user_worker is nil",firm.id,Time.now.to_datetime).order_by(start_datetime)
  end

  private

  def convert_times
    self.end_datetime = self.start_datetime + (self.duration_mins.hour * 3600) + (self.duration_mins.min * 60)
  end
end
