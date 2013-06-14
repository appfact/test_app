class FirmPermission < ActiveRecord::Base
  attr_accessible :kind, :user_id
  belongs_to :firm
  belongs_to :user

  validates :kind, presence: true

  private



end
