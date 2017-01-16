require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'active_model'
require 'tyrant/mailer'

module Tyrant
  class ResetPassword < Trailblazer::Operation
    step :model!
    step :generate_password!
    step :new_authentication!
    step :notify_user!

    def model!(options, params:, **)
      options["model"] = params[:model] #inject User model
    end
    
    def generate_password(options, new_password:, **)
      options["new_password"] = SecureRandom.base64[0,8]
    end

    def new_authentication(options, model:, **)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!(options["new_password"])
      auth.sync
    end

    def notify_user!(options, model:, **)
      Tyrant::Mailer.(email: model.email, new_password: options["new_password"])
    end
  end
end