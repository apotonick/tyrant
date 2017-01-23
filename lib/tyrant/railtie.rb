module Tyrant
  class Railtie < Rails::Railtie
    require "warden"

    # DISCUSS: this should actually use Tyrant::Session to log in and out user?
    config.app_middleware.use Warden::Manager do |config|
      Warden::Manager.serialize_into_session do |record|
        # Complex object should not be stored in session. Only the class name,
        # that will be use to reconstitute the user, is stored
        { model: record.class.name, id: record.id }
      end

      Warden::Manager.serialize_from_session do |record|
        case record[:model]
        when nil
          model = record['model']
        else          
          model = record[:model]
        end

        case record[:id]
        when nil
          id = record['id']
        else          
          id = record[:id]
        end

        model.constantize.find_by(id: id) # Session.sign_in!(user) or something!
      end
    end
  end
end