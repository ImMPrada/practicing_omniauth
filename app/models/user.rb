class User < ApplicationRecord
  before_validation :add_avatar_url, on: :create

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, uniqueness: true, presence: true
  validates :avatar_url, presence: true

  private

  def add_avatar_url
    self.avatar_url = "https://api.dicebear.com/6.x/bottts/svg?seed=#{username}"
  end
end
