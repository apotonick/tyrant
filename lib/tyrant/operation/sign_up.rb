require 'trailblazer'
require 'tyrant/contract/sign_up'

module Tyrant
  # SignUp will come and implement to-be-confirmed sign up.
  class SignUp < Trailblazer::Operation
    class Confirmed < Trailblazer::Operation
      step Trailblazer::Operation::Contract::Build(constant: Tyrant::Contract::SignUp)
      step Trailblazer::Operation::Contract::Validate()
      step Trailblazer::Operation::Contract::Persist()
      step :update!

      def update!(options, params:, model:, **)
        auth = Tyrant::Authenticatable.new(model)
        auth.digest!(params[:password]) # contract.auth_meta_data.password_digest = ..
        auth.confirmed!
        auth.sync
        model.save
      end
    end
  end
end