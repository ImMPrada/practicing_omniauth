module OmniAuthConcern
  extend ActiveSupport::Concern

  def authenticate
    email = auth.info.email
    return complete_user_sign_up if email.blank?

    user = User.find_by(email:)
    return create_user_and_login(auth) if user.blank?

    service = Service.find_by(uid: auth.uid, provider: auth.provider)
    return add_service_and_login(user) if service.blank?

    succesfully_sign_in_for_user(user)
  end

  private

  def add_service_and_login(user)
    service = Service.create_for_user(service_params, user)
    return succesfully_sign_in_for_user(user) if service.present?

    unsuccesfully_authentication
  end

  def create_user_and_login(auth)
    user = User.create_with_service(user_params, service_params)
    return succesfully_sign_in_for_user(user) if user.present?

    unsuccesfully_authentication
  end

  def complete_user_sign_up
    flash[:alert] = "#{auth.provider} doesn't tell us all required fields. Please complete your sign up."
    redirect_to(new_user_session_path)
  end

  def succesfully_sign_in_for_user(user)
    flash[:success] = "Welcome #{user.username}! you are logged in."
    sign_in_and_redirect(user, event: :authentication)
  end

  def unsuccesfully_authentication
    flash[:alert] = 'You can not login'
    redirect_to(new_user_session_path)
  end

  def user_params
    {
      email: auth.info.email,
      password: Devise.friendly_token[0, 20]
    }
  end

  def service_params
    {
      provider: auth.provider,
      uid: auth.uid,
      expires: auth.credentials.expires,
      expires_at: Time.at(auth.credentials.expires_at),
      token: auth.credentials.token
    }
  end
end
