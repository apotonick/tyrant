module Tyrant
  class Railtie < Rails::Railtie
      require "warden"

      # DISCUSS: it will be configurable what user class etc. and might be moved to Ops.
      # DISCUSS: this should actually use Tyrant::Session to log in and out user?
      config.app_middleware.use Warden::Manager do |config|
        Warden::Manager.serialize_into_session do |user|
          user.id
        end

        Warden::Manager.serialize_from_session do |id|
          User.find_by(id: id) # Session.sign_in!(user) or something!
        end
      end
  end
end