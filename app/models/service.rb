class Service < ApplicationRecord
  belongs_to :user

  validates :uid, uniqueness: { scope: :provider }, presence: true
  validates :provider, presence: true
  validates :token, presence: true

  def self.create_for_user(service_params, user)
    service = Service.new(service_params)
    user.services << service
    return nil unless service.save

    service
  end
end
