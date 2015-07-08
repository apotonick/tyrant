require "trailblazer/operation"
require "active_model"
require "reform/form/active_model/validations" # TODO: this will get replaced with Lotus.
require "reform/form/validation/unique_validator.rb"
module Tyrant
  class SignUp < Trailblazer::Operation
    class Confirmed < Trailblazer::Operation
      include CRUD
      model User, :create

      contract do
        include Reform::Form::ActiveModel::Validations

        property :email
        property :password, virtual: true
        property :confirm_password, virtual: true

        validates :email, :password, :confirm_password, presence: true
        # validates :email, email: true, unique: true
        validate :password_ok?

      private
        # TODO: more, like minimum 6 chars, etc.
        def password_ok?
          return unless email and password
          errors.add(:password, "Passwords don't match") if password != confirm_password
        end
      end


      # sucessful signup:
      # * hash password, set confirmed
      # * hash password, set unconfirmed with token etc.

      # * no password, unconfirmed, needs password.
      def process(params)
        validate(params[:user]) do |contract|
          update!

          contract.save # save User with email.
        end
      end

      def update!
        auth = Tyrant::Authenticatable.new(contract.model)
        auth.digest!(contract.password) # contract.auth_meta_data.password_digest = ..
        auth.confirmed!
        auth.sync
      end
    end
  end
end