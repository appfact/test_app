class FirmPermission < ActiveRecord::Base
  attr_accessible :kind, :user_id
  belongs_to :firm

  validates :kind, presence: true

  private



end
