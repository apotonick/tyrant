require "disposable/twin/struct"

module Tyrant
  class Authenticatable < Disposable::Twin
    property :auth_meta_data do
      include Struct
      property :confirmation_token
    end

    def confirmable?(token=nil)
      return false unless auth_meta_data # FIXME: handle this in Struct.
      persisted_token = auth_meta_data.confirmation_token

      # TODO: add expiry etc.
      return false unless (persisted_token.is_a?(String) and persisted_token.size > 0)

      return compare_token(token) if token
      true
    end

    # alias_method :confirmed?, :confirmable?
    def confirmed?
      return false unless auth_meta_data #FIXME, of course.
      return true if auth_meta_data.has_key?(:confirmation_token)  and auth_meta_data[:confirmation_token].nil?
      return false if auth_meta_data[:confirmation_token].size > 0
    end

  private
    def compare_token(token)
      token == auth_meta_data.confirmation_token
    end
  end
end