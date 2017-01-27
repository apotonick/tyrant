require 'trailblazer'
require 'tyrant/operation/get_new_password'

class Tyrant::ChangePassword < Trailblazer::Operation
  step Nested(Tyrant::GetNewPassword)
  step Trailblazer::Operation::Contract::Validate()
  failure :show_errors!,                                fail_fast: true
  step :model!
  step :policy!   
  failure :raise_error!
  step :update!   

  def model!(options, params:, **)
    options["model"] = User.find_by(email: params[:email])
  end

  def show_errors!(options, *)
  end

  def policy!(options, model:, current_user:, **)
    options["result.validate"] = (model.email == current_user.email)  
  end

  def raise_error!(options, *)
    raise NotAuthorizedError
  end

  def update!(options, model:, params:, **)
    auth = Tyrant::Authenticatable.new(model)
    auth.digest!(params[:new_password]) # contract.auth_ meta_data.password_digest = ..
    auth.sync
    model.save
  end
end