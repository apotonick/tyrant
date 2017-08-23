module Tyrant
  class ChangePassword < Trailblazer::Operation

    class GetNewPassword < Trailblazer::Operation
      step Contract::Build(constant: Form::ChangePassword)
    end

    step Nested( GetNewPassword )
    step Contract::Validate()
    failure :show_errors!,                                fail_fast: true
    step :model!
    step Policy::Guard(:authorize!)
    step :update!

    def model!(options, params:, **)
      options["model"] = User.find_by(email: params[:email])
    end

    #easy way to show the error in the validation
    def show_errors!(options, *)
    end

    def authorize!(options, model:, current_user:, **)
      model.email == current_user.email
    end

    def update!(options, model:, params:, **)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest!( options["contract.default"].new_password )
      auth.sync
      model.save
    end
  end # class ChangePassword
end # module Tyrant
