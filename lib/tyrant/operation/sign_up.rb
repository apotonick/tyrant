module Tyrant
  class SignUp < Trailblazer::Operation
    class Confirmed < Trailblazer::Operation
      step Model( ::User, :new )
      step Contract::Build( constant: Form::SignUp )
      step Contract::Validate()
      step Contract::Persist()
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
