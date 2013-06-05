class Shift < ActiveRecord::Base
  attr_accessible :description, :end_time, :fk_user_worker, :role, :start_time, :status
  belongs_to :user

  validates :user_id, presence: true
  validates :role, presence: true, length: {maximum:50}
end
