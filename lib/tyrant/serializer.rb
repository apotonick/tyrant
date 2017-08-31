require 'uri'
require 'json'
require 'net/http'

module Tyrant
  # this creates the correct logic to either serialize into or from an ActiveRecord with Model.find(id)
  # or just using the access_token (from third party ex: GitHub) to have a not persistent Struct as model/current_user
  # override serialize_into and serialize_from to use the methods provided or implement your own
  class Serializer

    def initialize(record)
      @record = record
    end

    def serialize_into
      model_into
    end

    def serialize_from
      model_from
    end

    def model_into
      { model: @record.class.name, id: @record.id}
    end

    def model_from
      @record['model'].constantize.find_by(id: @record['id'])
    end

    #expect OpenStruct/hash with access_token and url
    def url_into
      { url: @record['url'], access_token: @record['access_token']}
    end

    def url_from
      resp = Net::HTTP.get_response( get_uri(url: @record['url'], access_token: @record['access_token'] ) )

      result = JSON::parse(resp.body)
      return nil if result["message"] == "Bad credentials"
      return OpenStruct.new(result)
    end
  private
    def get_uri(url:, access_token:)
      uri = URI.parse(url)
      new_query_ar = URI.decode_www_form(uri.query || '') << ["access_token", access_token]
      uri.query = URI.encode_www_form(new_query_ar)

      return uri
    end

  end
end
