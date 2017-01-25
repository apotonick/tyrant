require 'reform'

module Tyrant::Contract
  class SignUp < Reform::Form
    feature Reform::Form::Dry

    property :email
    property :password, virtual: true
    property :confirm_password, virtual: true

    validation do
      configure do
        option :form
        config.messages_file = 'lib/config/error_messages.yml'

        def password_ok?
          return form.password == form.confirm_password
        end
      end
      
      required(:email).filled
      required(:password).filled
      required(:confirm_password).filled

      validate(password_ok?: :confirm_password) do
        password_ok?
      end
    end
  end
end