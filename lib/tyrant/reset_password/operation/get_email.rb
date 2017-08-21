require 'tyrant/reset_password/contract/get_email'

class Tyrant::GetEmail < Trailblazer::Operation
  step Contract::Build(constant: Form::GetEmail)
end
