class Tyrant::Mailer < Trailblazer::Operation
  module Form
    class Email < Reform::Form
      feature Reform::Form::Dry

      property :email, virtual: true
      property :reset_link, virtual: true

      validation do
        required(:email).filled
        required(:reset_link).filled
      end
    end # class Email
  end # module Form
end # class Tyrant::Mailer
