require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'trailblazer/operation/contract'
require 'trailblazer/operation/validate'
require 'trailblazer/operation/persist'
require "active_model"
require 'tyrant/contract/sign_up'

module Tyrant
  # SignUp will come and implement to-be-confirmed sign up.
  class SignUp < Trailblazer::Operation
    class Confirmed < Trailblazer::Operation
      step :model!
      step Trailblazer::Operation::Contract::Build(constant: ::Tyrant::Contract::SignUp)
      step Trailblazer::Operation::Contract::Validate()
      step :update!
      step Trailblazer::Operation::Contract::Persist(method: :sync)

      def model!(options, *)
        options["model"] = User.new
      end

      def update!(options, *)
        auth = Tyrant::Authenticatable.new(options["model"])
        auth.digest!(options["model"].password) # contract.auth_meta_data.password_digest = ..
        auth.confirmed!
        auth.sync
        model.save
      end
    end
  end
end