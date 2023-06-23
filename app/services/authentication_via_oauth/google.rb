module AuthenticationViaOauth
  class Google < SignupSignin

    private

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
end
