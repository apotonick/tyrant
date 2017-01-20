require "test_helper"

User = Struct.new(:id, :auth_meta_data, :email) do
  def save
    @saved = true
  end
  def persisted?
    @saved or false
  end
end

require "tyrant/sign_up"

class SignUpConfirmedTest < MiniTest::Spec
  Authenticatable = Tyrant::Authenticatable
  User = Struct.new(:auth_meta_data)
end

class SessionSignUpTest < MiniTest::Spec
  # successful.
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
  end

  # not filled out.
  it do
    res = Tyrant::SignUp::Confirmed.(
      email: "",
      password: "",
      confirm_password: "",
    )

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"must be filled\"], :password=>[\"must be filled\"], :confirm_password=>[\"must be filled\"]}"
  end

  # password mismatch.
  it do
    res = Tyrant::SignUp::Confirmed.(
      email: "selectport@trb.org",
      password: "123123",
      confirm_password: "wrong because drunk",
    )

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:confirm_password=>[\"Passwords don't match\"]}"
  end

  # email taken.
  # it do
  #   Session::SignUp::Confirmed.run(user: {
  #     email: "selectport@trb.org", password: "123123", confirm_password: "123123",
  #   })

  #   res, op = Session::SignUp::Confirmed.run(user: {
  #     email: "selectport@trb.org",
  #     password: "abcabc",
  #     confirm_password: "abcabc",
  #   })

  #   res.must_equal false
  #   op.model.persisted?.must_equal false
  #   op.errors.to_s.must_equal "{:email=>[\"email must be unique.\"]}"
  # end
end