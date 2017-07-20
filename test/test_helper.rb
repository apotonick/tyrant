$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tyrant'
require 'minitest/autorun'
require 'warden'
require 'active_record'
require 'trailblazer/operation'
require 'tyrant/operation/sign_up'

class MiniTest::Spec
  include Warden::Test::Mock

  after do
    Warden.test_reset!
    ::User.delete_all
  end
end

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db.sqlite3',
)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
    t.text   :auth_meta_data
  end
end

class User < ActiveRecord::Base
  serialize :auth_meta_data
end