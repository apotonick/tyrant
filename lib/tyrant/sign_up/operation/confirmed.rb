module Tyrant
  class SignUp < Trailblazer::Operation
    class Confirmed < SignUp
      step Contract::Build( constant: Form::WithConfirmPassword ), override: true
    end
  end
end
