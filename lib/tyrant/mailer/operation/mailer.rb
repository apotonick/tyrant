require 'pony'
require 'tyrant/mailer/contract/mail'
require 'tyrant/mailer/cell/reset_email'

module Tyrant

  class Mailer < Trailblazer::Operation
    step Trailblazer::Operation::Contract::Build(constant: Tyrant::Contract::Mail)
    step Trailblazer::Operation::Contract::Validate()
    step :email_options!
    step :send_email!

    def email_options!(options, via: :smtp, **)
      Pony.options = {
                      from: "admin@email.com",
                      via: via,
                      via_options: {
                                    address: "smtp.gmail.com",
                                    port: "587",
                                    domain: 'localhost:3000',
                                    enable_starttls_auto: true,
                                    user_name: "your_email@gmail.com",
                                    password: "your_password",
                                    authentication: :plain
                                    }
                      }
    end

    def send_email!(options, params:, **)
      Pony.mail( to: params[:email],
                  subject: "Reset password for your application",
                  html_body: Tyrant::Cell::ResetEmail.new(nil, reset_link: params[:reset_link], email: params[:email]).show
                )
    end
  end
end
