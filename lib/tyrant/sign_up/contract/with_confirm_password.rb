class Tyrant::SignUp < Trailblazer::Operation
  module Form
    # Add the confirm_password field to the Abstract form, and
    # the necessary equal? validation.
    class WithConfirmPassword < Abstract
      property :confirm_password, virtual: true

      validation with: { form: true } do
        # DISCUSS: does this really inherit the configure?
        configure do
          config.messages_file = File.join(File.dirname(__FILE__), "../../config/error_messages.yml") # FIXME: do this once.

          def must_be_equal?
            return form.password == form.confirm_password
          end
        end

        required(:confirm_password).filled

        validate(must_be_equal?: :confirm_password) do
          must_be_equal?
        end
      end
    end
  end
end
