module Tyrant
  # HTTP/Warden session-specific behavior.
  class Session
    def initialize(warden)
      @warden = warden
    end

    def current_user(options = {})
      @warden.user(options[:scope] || :default)
    end

    def signed_in?(options = {})
      @warden.user(options[:scope] || :default)
    end

    def sign_in!(user, options = {})
      options[:scope] ||= :default

      @warden.set_user(user, options)
    end

    # Sign out the default scope only if not specified.
    # Warden default behavior is to sign out every user if no scope is passed.
    def sign_out!(options = {})
      @warden.logout(options[:scope] || :default)
    end
  end
end
