require "disposable/twin/struct"

module Tyrant
  class Authenticatable < Disposable::Twin
    feature Default

    property :auth_meta_data, default: Hash.new do
      include Struct
      property :confirmation_token
      property :confirmed_at
    end

    module Confirm
      # without token, this decides whether the user model can be activated (e.g. via "set a password").
      # with token, this additionally tests if the token is correct.
      def confirmable?(token=nil)
        persisted_token = auth_meta_data.confirmation_token

        # TODO: add expiry etc.
        return false unless (persisted_token.is_a?(String) and persisted_token.size > 0)

        return compare_token(token) if token
        true
      end

      # alias_method :confirmed?, :confirmable?
      def confirmed?
        not auth_meta_data.confirmed_at.nil?
      end

      def confirm!(confirmed_at=DateTime.now)
        auth_meta_data.confirmation_token = nil
        auth_meta_data.confirmed_at       = confirmed_at # TODO: test optional arg.
      end

    private
      def compare_token(token)
        token == auth_meta_data.confirmation_token
      end
    end # Confirm
    include Confirm

  end
end