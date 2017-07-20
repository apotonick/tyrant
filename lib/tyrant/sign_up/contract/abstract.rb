class Tyrant::SignUp < Trailblazer::Operation
  module Form
    class Abstract < Reform::Form
      feature Reform::Form::Dry

      property :email
      property :password, virtual: true

      validation with: { form: true } do
        configure do
          config.messages_file = File.join(File.dirname(__FILE__), "../../config/error_messages.yml") # FIXME: do this once.

          def unique_email?
            User.where("email = ?", form.email).size == 0
          end

          def email?
            ! /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match(form.email).nil?
          end
        end

        required(:email).filled(:email?)
        required(:password).filled

        validate(unique_email?: :email) do
          unique_email?
        end
      end
    end
  end
end
