require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'trailblazer/operation/contract'
require 'trailblazer/operation/validate'
require 'active_model'
require 'securerandom'
require 'pony'
require 'tyrant/contract/mail'

module Tyrant  
  class Mailer < Trailblazer::Operation
    step Trailblazer::Operation::Contract::Build(constant: Tyrant::Contract::Mail)
    step Trailblazer::Operation::Contract::Validate()
    step :email_options!
    step :send_email!

    def email_options!(options, *)
      Pony.options = {
                      from: "admin@email.com",
                      via: :smtp, 
                      via_options: {
                                    address: "smtp.gmail.com", 
                                    port: "587",
                                    domain: 'localhost:3000', 
                                    enable_starttls_auto: true, 
                                    user_name: "your_email@gmail.com", 
                                    password: "your_password", 
                                    subject: "Reset password for your application",
                                    authentication: :plain
                                    } 
                      }
    end
    
    def send_email!(options, params:, **)
      Pony.mail({ to: params[:email],
                  body: "Hi there, here is your temporary password: #{params[:new_password]}. We suggest you to modify this password ASAP. Cheers",
                })
    end
  end
end