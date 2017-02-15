require 'trailblazer/cell'
require 'action_view'
require 'formular'

module Tyrant::Cell
  class ResetPassword < Trailblazer::Cell
    include ActionView::RecordIdentifier
    include ActionView::Helpers::FormOptionsHelper
    include Formular::RailsHelper
    include Formular::Helper

    self.view_paths << File.absolute_path("lib")
  end
end