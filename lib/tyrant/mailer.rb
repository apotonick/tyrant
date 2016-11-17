require 'trailblazer/operation'
require 'trailblazer/operation/model'
require 'active_model'
require 'reform/form/validate'
require 'reform/form/active_model/validations'
require 'securerandom'
require 'pony'

module Tyrant  
  class Mailer < Trailblazer::Operation

    contract do
      include Reform::Form::ActiveModel::Validations

      property :email, virtual: true
      property :new_password, virtual: true

      validates :email, :new_password, presence: true
    end

    def process(params)
      validate(params) do
        email_options #override for Pony/email options 
        notify_user(params[:email], params[:new_password]) #override to have a cooler email layout
      end
    end

  private
    def email_options
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
    
    def notify_user(email, new_password)
      Pony.mail({ to: email,
                  body: "Hi there, here is your temporary password: #{new_password}. We suggest you to modify this password ASAP. Cheers",
                })
    end
  end
end