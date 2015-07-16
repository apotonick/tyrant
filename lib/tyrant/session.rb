module Tyrant
  # HTTP/Warden session-specific behavior.
  class Session
    def initialize(warden)
      @warden = warden
    end

    def current_user
      @warden.user
    end

    def signed_in?
      @warden.user
    end

    def sign_in!(user)
      @warden.set_user(user)
    end

    def sign_out!
      @warden.logout
    end
  end
end