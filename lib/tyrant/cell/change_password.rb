module Tyrant::Cell
  class ChangePassword < Trailblazer::Cell
    include ActionView::RecordIdentifier
    include ActionView::Helpers::FormOptionsHelper
    include Formular::RailsHelper
    include Formular::Helper

    self.view_paths << '/home/emamaglio/projects/tyrant/lib'
  end
end