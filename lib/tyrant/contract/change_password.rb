require 'reform/form/dry'

module Tyrant::Contract
  class ChangePassword < Reform::Form
    feature Reform::Form::Dry

    property :email, virtual: true
    property :password, virtual: true
    property :new_password, virtual: true
    property :confirm_new_password, virtual: true

    validation with: { form: true } do
      configure do
        config.messages_file = File.join(File.dirname(__FILE__), "../config/error_messages.yml")

        def user_exists?
          User.where(email: form.email).size == 1
        end

        def new_must_match?
          return form.new_password == form.confirm_new_password
        end

        def new_password_must_be_new?
          return form.password != form.new_password
        end

        def password_ok?
          return Tyrant::Authenticatable.new(User.find_by(email: form.email)).digest?(form.password) == true if user_exists?
        end

      end

      required(:email).filled(:user_exists?)
      required(:password).filled
      required(:new_password).filled
      required(:confirm_new_password).filled

      validate(password_ok?: :password) do
        password_ok?
      end

      validate(new_password_must_be_new?: :new_password) do
        new_password_must_be_new?
      end

      validate(new_must_match?: :confirm_new_password) do
        new_must_match?
      end

    end
  end
end
