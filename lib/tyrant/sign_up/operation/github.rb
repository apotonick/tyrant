require 'uri'
require 'net/http'
require 'json'

module Tyrant

  class SignUp::GitHub < Trailblazer::Operation

    step Policy::Guard(:match_state!)
    step :check_client_id!
    step :check_client_secret!
    step :get_access_token!
    step :get_user_hash!
    step :model!

    def match_state!(options, params:, **)
      options["failure_message"] = "State has not been set" if !options["state"]
      return false if !options["state"]

      params["state"] == options["state"]
    end

    def check_client_id!(options, *)
      options["failure_message"] = "Client_id has not been set" if !options["client_id"]
      options["client_id"]
    end

    def check_client_secret!(options, *)
      options["failure_message"] = "Client_secret has not been set" if !options["client_secret"]
      options["client_secret"]
    end

    def get_access_token!(options, params:, **)
      options["url"] = 'https://github.com/login/oauth/access_token'
      options["args"] = []
      options["args"] << ["code", params[:code]] << ["client_id", options["client_id"]] << ["client_secret", options["client_secret"]]
      options["args"] << ["redirect_uri", options["redirect_uri"]] if options["redirect_uri"] != nil

      resp = Net::HTTP.get_response( get_uri!(options) )

      options["access_token_hash"] = {}
      resp.body.split('&').each do |element|
        array = element.split('=')
        options["access_token_hash"][array.first] = array.last
      end

      if options["access_token_hash"]["Not Found"]
        options["failure_message"] = "Wrong client_id or/and client_secret"
        return false
      end
      true
    end

    def get_user_hash!(options, access_token_hash:, **)
      options["url"] = 'https://api.github.com/user'
      options["args"] = ["access_token", access_token_hash["access_token"]]

      resp = Net::HTTP.get_response( get_uri!(options) )

      options["user_hash"] = JSON.parse(resp.body)
      return false if options["user_hash"]["message"] == "Bad credentials"
      true
    end

    def model!(options, access_token_hash:, user_hash:, **)
      options["model"] = OpenStruct.new(user_hash.merge(access_token_hash))
      true
    end

  private
    def get_uri!(options)
      uri = URI.parse(options["url"])

      if options["args"].first.class == Array
        options["args"].each do |arg|
          new_query_ar = URI.decode_www_form(uri.query || '') << arg
          uri.query = URI.encode_www_form(new_query_ar)
        end
      else
        new_query_ar = URI.decode_www_form(uri.query || '') << options["args"]
        uri.query = URI.encode_www_form(new_query_ar)
      end

      return uri
    end

  end # class SignUp::GitHub

end # module Tyrant
