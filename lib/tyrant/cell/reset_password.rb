require 'trailblazer/cell'
require 'action_view'
require 'formular'

module Tyrant::Cell
  class ResetPassword < Trailblazer::Cell
    include ActionView::RecordIdentifier
    include ActionView::Helpers::FormOptionsHelper
    include Formular::RailsHelper
    include Formular::Helper

    current_file = []
    Pathname.new(File.dirname(__FILE__)).ascend {|v| current_file << v}
    view_file = current_file[2]

    self.view_paths << view_file
  end
end