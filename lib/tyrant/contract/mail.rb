require 'reform'
require 'reform/form/dry'

module Tyrant::Contract
  class Mail < Reform::Form 
    feature Reform::Form::Dry

    property :email, virtual: true
    property :new_password, virtual: true

    validate do
      required(:email).filled
      required(:new_password).filled
    end
  end
end