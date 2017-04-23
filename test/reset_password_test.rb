require "test_helper"

class ResetPasswordTest < MiniTest::Spec
  it 'wrong input' do
    res = Tyrant::SignUp::Confirmed.(
      email: "resetwrong@trb.org",
      password: "123123",
      confirm_password: "123123",
    )
    res.success?.must_equal true
    res["model"].email.must_equal "resetwrong@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    res = Tyrant::ResetPassword.({email: "wrong@trb.org"})

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"User not found\"]}"
  end

  it 'reset password successfully' do
    res = Tyrant::SignUp::Confirmed.(
      email: "reset@trb.org",
      password: "123123",
      confirm_password: "123123",
    )

    res.success?.must_equal true
    res["model"].email.must_equal "reset@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    new_password = -> { "NewPassword" }

    res = Tyrant::ResetPassword.({email: "reset@trb.org"}, "generator" => new_password, "via" => :test)

    res.success?.must_equal true
    res["model"].email.must_equal "reset@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest != "123123"
    assert Tyrant::Authenticatable.new(res["model"]).digest == "NewPassword"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    Mail::TestMailer.deliveries.length.must_equal 1
    Mail::TestMailer.deliveries.first.to.must_equal ["reset@trb.org"]
    Mail::TestMailer.deliveries.first.body.raw_source.must_equal "Hi there, here is your temporary password: NewPassword. We suggest you to modify this password ASAP. Cheers"
  end
end

