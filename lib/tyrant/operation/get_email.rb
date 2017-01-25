class Tyrant::GetEmail < Trailblazer::Operation
  step Trailblazer::Operation::Contract::Build(constant: ::Tyrant::Contract::GetEmail)
end