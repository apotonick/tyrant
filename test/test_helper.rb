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

#to test that a new password "NewPassword" is actually saved 
#in the auth_meta_data in User
Tyrant::ResetPassword.class_eval do 
  def generate_password
    return "NewPassword"
  end
end

#to test the email notification to the user for the ResetPassword
Tyrant::Mailer.class_eval do 
  def email_options
    Pony.options = {via: :test}
  end  
end
