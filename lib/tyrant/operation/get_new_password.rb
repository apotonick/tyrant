require 'trailblazer'
require 'tyrant/contract/change_password'

class Tyrant::GetNewPassword < Trailblazer::Operation
  step Trailblazer::Operation::Contract::Build(constant: Tyrant::Contract::ChangePassword) 
end