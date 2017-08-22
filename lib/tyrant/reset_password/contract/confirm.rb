module Tyrant::ResetPassword
  class Confirm < Trailblazer::Operation

    class GetNewPassword < Trailblazer::Operation
      module Form
        class Confirm < Reform::Form
          feature Reform::Form::Dry

          property :email, virtual: true
          property :safe_url, virtual: true
          property :new_password, virtual: true
          property :confirm_new_password, virtual: true

          validation with: { form: true } do
            configure do
              config.messages_file = File.join(File.dirname(__dir__), '../config/error_messages.yml') # FIXME: do this once.

              def new_must_match?
                form.new_password == form.confirm_new_password
              end

              def safe_url_ok?
                Tyrant::Authenticatable.new(User.find_by(email: form.email)).digest_reset_password?(form.safe_url) if form.email
              end

              def safe_url_expired?
                !Tyrant::Authenticatable.new(User.find_by(email: form.email)).reset_password_expired? if form.email
              end

            end

            required(:email).filled
            required(:safe_url).filled(:safe_url_ok?, :safe_url_expired?)
            required(:new_password).filled(:new_must_match?)
            required(:confirm_new_password).filled(:new_must_match?)
          end
        end # class Confirm
      end # module Form
    end # class GetNewPassword
  end # class Confirm
end # module Tyrant::ResetPassword
