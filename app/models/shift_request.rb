class ShiftRequest < ActiveRecord::Base
  attr_accessible :manager_id, :manager_status, :worker_id, :worker_status

  belongs_to :shift
  belongs_to :worker, class_name: "User"
  belongs_to :manager, class_name: "User"

  validates :shift_id, presence: true
end
