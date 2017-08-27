require 'uri'
require 'json'
require 'net/http'

module Tyrant
  # this creates the correct logic to either serialize into or from an ActiveRecord with Model.find(id)
  # or just using the access_token (from third party ex: GitHub) to have a not persistent Struct as model/current_user
  class Serializer

    def initialize(record)
      @record = record
      @type = ""
      set_type()
    end

    def serialize_into
      @type == "model" ? model_into : url_into
    end

    def serialize_from
      @type == "model" ? model_from : url_from
    end

  private
    def set_type
      if @record.class.name == "Hash"
        @record['model'] ? @type="model" : @type="url"
      else
        (@record.is_a? ActiveRecord::Base) ? @type="model" : @type="url"
      end
    end

    def model_into
      { model: @record.class.name, id: @record.id}
    end

    #expect OpenStruct with access_token and request url
    def url_into
      { url: @record.url, access_token: @record.access_token}
    end

    def model_from
      @record['model'].constantize.find_by(id: @record['id'])
    end

    def url_from
      resp = Net::HTTP.get_response( get_uri(url: @record['url'], access_token: @record['access_token'] ) )

      result = JSON::parse(resp.body)
      return nil if result["message"] == "Bad credentials"
      return OpenStruct.new(result)
    end

    def get_uri(url:, access_token:)
      uri = URI.parse(url)
      new_query_ar = URI.decode_www_form(uri.query || '') << ["access_token", access_token]
      uri.query = URI.encode_www_form(new_query_ar)

      return uri
    end

  end
end
