module Tyrant::ResetPassword
  class Confirm < Trailblazer::Operation

    class GetNewPassword < Trailblazer::Operation
      step Contract::Build(constant: Form::Confirm)
    end # class GetNewPassword

    step Nested( GetNewPassword )
    step Contract::Validate()
    failure :show_errors!,                                fail_fast: true
    step :model!
    step :update!
    step :save!

    #easy way to show the error in the validation
    def show_errors!(options, *)
    end

    def model!(options, params:, **)
      options["model"] = User.find_by(email: params[:email])
    end

    def update!(options, model:, params:, **)
      auth = Tyrant::Authenticatable.new(model)
      # update new password
      auth.digest!( options["contract.default"].new_password ) # contract.auth_ meta_data.password_digest = ..
      auth.confirmed!

      # make the reset password expired
      auth.reset_password_expired!

      auth.sync
    end

    def save!(options, model:, **)
      model.save
    end

  end # class Confirm
end # class Tyrant::ResetPassword
