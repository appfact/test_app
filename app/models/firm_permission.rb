class FirmPermission < ActiveRecord::Base
  attr_accessible :type, :user_id
  belongs_to :firm

  validates :type, presence: true
end
