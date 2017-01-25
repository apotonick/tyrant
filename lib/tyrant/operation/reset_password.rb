require 'trailblazer'
require 'tyrant/operation/mailer'
require 'tyrant/operation/get_email'

module Tyrant
  class ResetPassword < Trailblazer::Operation
    step Nested(Tyrant::GetEmail)
    step Trailblazer::Operation::Contract::Validate()
    step :model!
    step :generate_password!
    step :new_authentication!
    step :notify_user!

    def model!(options, params:, **)
      options["model"] = User.find_by(email: params[:email])
    end

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