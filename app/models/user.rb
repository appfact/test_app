# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  phone         :string(255)
#  sign_up_stage :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :phone, :password, :password_confirmation, :business_id, :sign_up_stage
  has_secure_password
  has_many :shifts, dependent: :destroy
  has_many :firm_permissions, dependent: :destroy

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 }, 
  			format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  after_validation { self.errors.messages.delete(:password_digest) }

  def feed
  Shift.from_feed_logic(self)
  # from_feed_logic is a method that takes variable self
  end

  def feed2
  Shift.from_feed_logic_past(self)
  # from_feed_logic is a method that takes variable self
  end

  def feed3
    Shift.from_feed_logic_all(self)
  # from_feed_logic is a method that takes variable self
  end

  def open_shifts
    Shift.open_shifts_logic(self)
  end

  def self.available_users_logic(shiftx)
    where("business_id = ?", shiftx.firm_id)
  end

 


  private

    def create_remember_token
      self.remember_token.nil? ? self.remember_token = SecureRandom.urlsafe_base64 : self.remember_token = self.remember_token
    end
end
