module Tyrant::ResetPassword
  class Request < Trailblazer::Operation

    class GetEmail < Trailblazer::Operation

      module Form
        class Request < Reform::Form
          feature Reform::Form::Dry

          property :email, virtual: true

          validation with: { form: true } do
            configure do
              config.messages_file = File.join(File.dirname(__dir__), '../config/error_messages.yml') # FIXME: do this once.

              def user_exists?
                return User.find_by(email: form.email) != nil
              end
            end
            required(:email).filled

            validate(user_exists?: :email) do
              user_exists?
            end
          end
        end # class Request
      end # module Form
    end # class GetEmail
  end # class Request
end # module Tyrant::ResetPassword
