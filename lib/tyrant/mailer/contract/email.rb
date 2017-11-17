class Tyrant::Mailer < Trailblazer::Operation
  module Form
    class Email < Reform::Form
      feature Reform::Form::Dry

      property :email, virtual: true
      property :new_password, virtual: true

      validation do
        required(:email).filled
        required(:new_password).filled
      end
    end
  end
end
