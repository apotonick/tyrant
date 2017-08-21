require 'reform'
require 'reform/form/dry'

module Tyrant::Contract
  class Mail < Reform::Form
    feature Reform::Form::Dry

    property :email, virtual: true
    property :reset_link, virtual: true

    validation do
      required(:email).filled
      required(:reset_link).filled
    end
  end
end
