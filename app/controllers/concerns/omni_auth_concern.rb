module OmniAuthConcern
  extend ActiveSupport::Concern

  def resolve_authentication_or_add_service
    return authenticate unless user_signed_in?

    add_service_to_user
  end

  def add_service_to_user
    service = Service.create_for_user(service_params, current_user)
    return succesfully_sign_in_for_user(current_user) if service.present?

    unsuccesfully_authentication
  end

  def authenticate
    service = Service.find_by(uid: auth.uid, provider: auth.provider)
    return authenticate_with_service(service) unless service.blank?
    
    email = auth.info.email
    return complete_user_sign_up if email.blank?
    
    user = User.find_by(email:)
    return create_user_and_login(auth) if user.blank?

    add_service_and_login(user)
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
    redirect_to(new_user_registration_path)
  end

  def succesfully_sign_in_for_user(user)
    flash[:success] = "Welcome #{user.username}! you are logged in."
    sign_in_and_redirect(user, event: :authentication)
  end

  def authenticate_with_service(service)
    user = service.user
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
      username:,
      password: Devise.friendly_token[0, 20]
    }
  end

  def service_params
    {
      provider: auth.provider,
      uid: auth.uid,
      expires: token_expires?,
      expires_at: token_expiration_date,
      token: auth.credentials.token
    }
  end

  def token_expiration_date
    return nil unless token_expires?

    Time.at(auth.credentials.expires_at)
  end

  def token_expires?
    auth.credentials.expires
  end

  def username
    auth.info.username
  end
end
