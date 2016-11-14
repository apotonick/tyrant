require "test_helper"
require "sign_up_test"
require "tyrant/sign_up"
require "tyrant"

User = Struct.new(:id, :auth_meta_data, :email) do
  def save
    @saved = true
  end
  def persisted?
    @saved or false
  end
end

class SignUpConfirmedTest < MiniTest::Spec
  Authenticatable = Tyrant::Authenticatable
  User = Struct.new(:auth_meta_data)
end

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

    op = Tyrant::ResetPassword.(op.model)

    op.model.persisted?.must_equal true
    op.model.email.must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(op.model).digest != "123123"
    assert Tyrant::Authenticatable.new(op.model).digest == "NewPassword"
    Tyrant::Authenticatable.new(op.model).confirmed?.must_equal true
    Tyrant::Authenticatable.new(op.model).confirmable?.must_equal false

  end
  
end

