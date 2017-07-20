module Tyrant::Contract
  class SignUp < Reform::Form
    feature Reform::Form::Dry

    property :email
    property :password, virtual: true
    property :confirm_password, virtual: true

    validation with: { form: true } do
      configure do
        config.messages_file = File.join(File.dirname(__FILE__), "../config/error_messages.yml") # FIXME: do this once.

        def unique_email?
          User.where("email = ?", form.email).size == 0
        end

        def email?
          ! /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match(form.email).nil?
        end

        def must_be_equal?
          return form.password == form.confirm_password
        end
      end

      required(:email).filled(:email?)
      required(:password).filled
      required(:confirm_password).filled

      validate(unique_email?: :email) do
        unique_email?
      end

      validate(must_be_equal?: :confirm_password) do
        must_be_equal?
      end
    end
  end
end
