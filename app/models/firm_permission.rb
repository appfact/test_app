class FirmPermission < ActiveRecord::Base
  attr_accessible :type
  belongs_to :firm

  validates :type, presence: true
end
