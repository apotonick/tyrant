require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'active_model'
require 'tyrant/operation/mailer'

module Tyrant
  class ResetPassword < Trailblazer::Operation
    step :model!
    step :generate_password!
    step :new_authentication!
    step :notify_user!

    def model!(options, params:, **)
      options["model"] = params[:model] #inject User model
    end
    
    def generate_password!(options, *)
      options["new_password"] = SecureRandom.base64[0,8]
    end

    def new_authentication!(options, model:, new_password:, **)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!(new_password)
      auth.sync
      model.save
    end

    def notify_user!(options, model:, new_password:, **)
      Tyrant::Mailer.({email: model.email, new_password: new_password})
    end
  end
end