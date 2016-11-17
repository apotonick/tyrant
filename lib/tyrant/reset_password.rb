require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'active_model'
require 'reform/form/validate'
require 'reform/form/active_model/validations'
require 'tyrant/mailer'

module Tyrant
  class ResetPassword < Trailblazer::Operation

    def model!(params)
      params[:model] #inject User model
    end

    def process(params)
      new_authentication
      model.save
    end

  private
    def new_authentication
      auth = Tyrant::Authenticatable.new(model)
      new_password = generate_password
      auth.digest!(new_password)
      auth.sync
      Tyrant::Mailer.(email: model.email, new_password: new_password)
    end

    def generate_password
      return SecureRandom.base64[0,8]
    end
  end
end