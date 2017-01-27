require "test_helper"
require 'active_record'

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
end


class ResetPasswordTest < MiniTest::Spec
  it 'wrong input' do
    res = Tyrant::SignUp::Confirmed.(
      email: "selectport@trb.org",
      password: "123123",
      confirm_password: "123123",
    )
    res.success?.must_equal true
    res["model"].email.must_equal "selectport@trb.org"

  end

  it 'reset password successfully' do
    res = Tyrant::SignUp::Confirmed.(
      email: "selectport@trb.org",
      password: "123123",
      confirm_password: "123123",
    )

    res.success?.must_equal true
    res["model"].email.must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    new_password = -> { "NewPassword" }

    res = Tyrant::ResetPassword.({email: "selectport@trb.org"}, "generator" => new_password, "via" => :test)

    res.success?.must_equal true
    res["model"].email.must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest != "123123"
    assert Tyrant::Authenticatable.new(res["model"]).digest == "NewPassword"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    Mail::TestMailer.deliveries.length.must_equal 1
    Mail::TestMailer.deliveries.first.to.must_equal ["selectport@trb.org"]
    Mail::TestMailer.deliveries.first.body.raw_source.must_equal "Hi there, here is your temporary password: NewPassword. We suggest you to modify this password ASAP. Cheers"
  end
end

