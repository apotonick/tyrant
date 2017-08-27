module Tyrant
  class Railtie < Rails::Railtie
    require "warden"

    # DISCUSS: this should actually use Tyrant::Session to log in and out user?
    config.app_middleware.use Warden::Manager do |config|
      Warden::Manager.serialize_into_session do |record|
        # Complex object should not be stored in session. Only the class name,
        # that will be use to reconstitute the user, is stored
        Tyrant::Serializer.new(record).serialize_into
      end

      Warden::Manager.serialize_from_session do |record|
        Tyrant::Serializer.new(record).serialize_from
      end
    end
  end
end
