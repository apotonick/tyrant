require 'trailblazer'
require 'tyrant/operation/mailer'
require 'tyrant/operation/get_email'

module Tyrant
  class ResetPassword < Trailblazer::Operation
    step Nested(Tyrant::GetEmail)
    step Trailblazer::Operation::Contract::Validate()
    failure :show_errors!, fails_fast: true
    step :model!
    step :generate_password!
    step :new_authentication!
    step :notify_user!

    def show_errors!(options, *)
    end

    def model!(options, params:, user: GetUser, **)
      options["model"] = user
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
    GetUser = -> { User.find_by(email: params[:email]) }

  end
end