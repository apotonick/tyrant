require "test_helper"
require "sign_up_test"
require "tyrant/operation/sign_up"
require "tyrant"

User = Struct.new(:id, :auth_meta_data, :email) do
  def save
    @saved = true
  end
  def persisted?
    @saved or false
  end
end

class ResetPasswordTest < MiniTest::Spec
  it do
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

