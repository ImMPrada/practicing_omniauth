class User < ApplicationRecord
  before_validation :add_avatar_url, :add_username, on: :create

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github]

  has_many :services, dependent: :destroy

  validates :username, uniqueness: true, presence: true
  validates :avatar_url, presence: true
  
  def google
    services.find_by(provider: 'google_oauth2')
  end

  def github
    services.find_by(provider: 'github')
  end

  private

  def add_avatar_url
    self.avatar_url = "https://api.dicebear.com/6.x/bottts/svg?seed=#{username}" if self.avatar_url.blank?
  end

  def add_username
    self.username = email.split('@').first if self.username.blank?
  end

  def self.create_with_service(user_params, service_params)
    user = User.new(user_params)
    service = Service.new(service_params)
    return nil unless user.save

    user.services << service
    service.save
    user
  end
end
