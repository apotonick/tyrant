require 'trailblazer'
require 'tyrant/operation/mailer'

module Tyrant
  class ResetPassword < Trailblazer::Operation
    step :generate_password!
    step :new_authentication!
    step :notify_user!
    
    def generate_password!(options, generator: PasswordGenerator,  **)
      options["new_password"] = generator.()
    end

    def new_authentication!(options, model:, new_password:, **)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!(new_password)
      auth.sync
      model.save
    end

    def notify_user!(options, model:, new_password:, mailer: Mailer, via: :smtp,  **)
      mailer.({email: model.email, new_password: new_password}, "via" => via)
    end

    PasswordGenerator = -> { SecureRandom.base64[0,8] }

  end
end