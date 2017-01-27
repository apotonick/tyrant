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