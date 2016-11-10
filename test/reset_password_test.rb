require "test_helper"
require "sign_up_test"

class ResetPasswordTest < MiniTest::Spec
  it do
    res, op = Tyrant::SignUp::Confirmed.run(user: {
      email: "selectport@trb.org",
      password: "123123",
      confirm_password: "123123",
    })

    op.model.persisted?.must_equal true
    op.model.email.must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(op.model).digest == "123123"
    Tyrant::Authenticatable.new(op.model).confirmed?.must_equal true
    Tyrant::Authenticatable.new(op.model).confirmable?.must_equal false
  end
  
end

