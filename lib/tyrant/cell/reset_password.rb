module Tyrant::Cell
  class ResetPassword < Trailblazer::Cell
    include ActionView::RecordIdentifier
    include ActionView::Helpers::FormOptionsHelper
    include Formular::RailsHelper
    include Formular::Helper

    self.view_paths = "tyrant/view"
  end
end