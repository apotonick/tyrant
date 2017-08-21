require 'trailblazer/cell'
require 'cells-slim'
require 'pathname'
require 'action_view'

module Tyrant::Cell
  class ResetEmail < Trailblazer::Cell
    include ::Cell::Slim
    include ::ActionView::Helpers::UrlHelper

    self.view_paths << Pathname(__FILE__).ascend{|d| d; break d if d.split.last.to_s == "mailer"}

    def self.controller_path
      util.underscore('view').split("/")[-1]
    end

    def show
      render :reset_email
    end

    def link
      link_to "Reset Password", options[:reset_link]
    end

  end # class ResetPassword

end # module Tyrant::Mailer::Cell
