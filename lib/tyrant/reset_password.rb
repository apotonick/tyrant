require 'securerandom'
require "trailblazer/operation"
require "trailblazer/operation/model"
require "active_model"
require "reform/form/validate"
require "reform/form/active_model/validations"

module Tyrant
  class ResetPassword
    # include Model
    # model User, :find
    
    # def process(params)
    #   new_authentication(model)
    # end

  # private
    def new_authentication(model)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!(generate_password) # contract.auth_meta_data.password_digest = ..
      auth.confirmed!
      auth.sync
      notify_user(model.email)
      return model
    end

    def generate_password
      # return SecureRandom.base64
      return "NewPassword"
    end

    def notify_user(email)

    end
  end
end