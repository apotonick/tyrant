require 'securerandom'

module Tyrant
  class ResetPassword
    
    def new_authentication(model)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!(generate_password) # contract.auth_meta_data.password_digest = ..
      auth.confirmed!
      auth.sync
      notify_user(model.email)
    end

    def generate_password
      # return SecureRandom.base64
      return "NewPassword"
    end

    def notify_user(email)

    end
  end
end