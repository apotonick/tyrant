require 'tyrant/mailer/operation/mailer'
require 'uri'

module Tyrant::ResetPassword
  class Request < Trailblazer::Operation

    class GetEmail < Trailblazer::Operation
      step Contract::Build(constant: Form::Request)
    end # class GetEmail

    step Nested( GetEmail )
    step Contract::Validate()
    step :url_exist!
    failure :show_errors!, fails_fast: true
    step :model!
    step :generate_password!
    step :reset_password!
    step :reset_link!
    step :notify_user!

    def url_exist!(options, *)
      return false if !options["url"]
      true
    end

    def show_errors!(options, *)
    end

    def model!(options, params:, **)
      options["model"] = User.find_by(email: params[:email])
    end

    def generate_password!(options, generator: PasswordGenerator,  **)
      options["safe_url"] = generator.()
    end

    def reset_password!(options, model:, safe_url:, **)
      auth = Tyrant::Authenticatable.new(model)
      auth.digest_reset_password!(safe_url)
      auth.sync
      model.save
    end

    def reset_link!(options, params:, safe_url:, url:, **)
      uri = URI.parse(url)
      new_query_ar = URI.decode_www_form(uri.query || '') << ["safe_url", safe_url] << ["email", params[:email]]
      uri.query = URI.encode_www_form(new_query_ar)

      options["reset_link"] = uri.to_s
    end

    def notify_user!(options, model:, reset_link:, mailer: Tyrant::Mailer, via: :smtp,  **)
      mailer.({email: model.email, reset_link: reset_link}, "via" => via)
    end

    PasswordGenerator = -> { SecureRandom.urlsafe_base64 }
  end # class Request
end # module Tyrant::ResetPassword
