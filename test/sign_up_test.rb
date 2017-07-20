require "test_helper"

class SessionSignUpTest < MiniTest::Spec
  it 'signup successfully' do
    res = Tyrant::SignUp::Confirmed.({email: "selectport@trb.org", password: "123123", confirm_password: "123123"})

    res.success?.must_equal true
    res["model"].email.must_equal "selectport@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false
  end

  it "not filled out" do
    res = Tyrant::SignUp::Confirmed.({email: "", password: "", confirm_password: ""})

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"must be filled\", \"Wrong format\"], :password=>[\"must be filled\"], :confirm_password=>[\"must be filled\"]}"
  end

  it "password mismatch" do
    res = Tyrant::SignUp::Confirmed.({email: "user@trb.org", password: "123123", confirm_password: "Wrong because drunk"})

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:confirm_password=>[\"Passwords are not matching\"]}"
  end

  it "unique email" do
    res = Tyrant::SignUp::Confirmed.({email: "user2@trb.org", password: "123123", confirm_password: "123123"})

    res.success?.must_equal true
    res["model"].email.must_equal "user2@trb.org"

    res = Tyrant::SignUp::Confirmed.({email: "user2@trb.org", password: "123123", confirm_password: "123123"})

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"This email has been already used\"]}"
  end

end
