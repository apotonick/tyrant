$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tyrant'

require 'minitest/autorun'

require 'warden'

class MiniTest::Spec
  include Warden::Test::Mock

  after do
    Warden.test_reset!
  end
end

Tyrant::ResetPassword.class_eval do
  def generate_password
    return "NewPassword"
  end

  def notify(email, password)
    #need to test this better
  end
end
