require "test_helper"

class ChangePasswordTest < MiniTest::Spec
  it 'wrong input' do
    res = Tyrant::SignUp::Confirmed.(
      email: "changewrong@trb.org",
      password: "123123",
      confirm_password: "123123",
    )
    res.success?.must_equal true
    res["model"].email.must_equal "changewrong@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    res = Tyrant::ChangePassword.({email: "wrong@trb.org", password: "wrong"})

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"User not found\"], :password=>[\"Wrong Password\"], :new_password=>[\"is missing\"], :confirm_new_password=>[\"is missing\"]}"
  end

  it "wrong new password" do
     res = Tyrant::SignUp::Confirmed.(
      email: "wrongpassword@trb.org",
      password: "123123",
      confirm_password: "123123",
    )
    res.success?.must_equal true
    res["model"].email.must_equal "wrongpassword@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false

    res = Tyrant::ChangePassword.({email: "wrongpassword@trb.org", password: "123123", new_password: "123123", confirm_new_password: "different"})

    res.failure?.must_equal true
    res["result.contract.default"].errors.messages.inspect.must_equal "{:new_password=>[\"New password can't match the old one\"], :confirm_new_password=>[\"The New Password is not matching\"]}"
  end

  it "false policy" do 
    user1 = Tyrant::SignUp::Confirmed.(
      email: "user1@trb.org",
      password: "123123",
      confirm_password: "123123",
    )
    user1.success?.must_equal true
    user1["model"].email.must_equal "user1@trb.org"

    assert Tyrant::Authenticatable.new(user1["model"]).digest == "123123"
    Tyrant::Authenticatable.new(user1["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(user1["model"]).confirmable?.must_equal false

    user2 = Tyrant::SignUp::Confirmed.(
      email: "user2@trb.org",
      password: "123123",
      confirm_password: "123123",
    )
    user2.success?.must_equal true
    user2["model"].email.must_equal "user2@trb.org"

    RaiseNoError = -> {}

    #user2 trying to change password
    res = Tyrant::ChangePassword.({ email: "user1@trb.org", 
                                    password: "123123", 
                                    new_password: "NewPassword", 
                                    confirm_new_password: "NewPassword"},
                                   "current_user" => user2["model"], "error_handler" => RaiseNoError)

    res.failure?.must_equal true
    assert Tyrant::Authenticatable.new(user1["model"]).digest == "123123"
    Tyrant::Authenticatable.new(user1["model"]).confirmed?.must_equal true
  end

  it 'change password successfully' do
    user = Tyrant::SignUp::Confirmed.(
      email: "change@trb.org",
      password: "123123",
      confirm_password: "123123",
    )

    user.success?.must_equal true
    user["model"].email.must_equal "change@trb.org"

    assert Tyrant::Authenticatable.new(user["model"]).digest == "123123"
    Tyrant::Authenticatable.new(user["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(user["model"]).confirmable?.must_equal false

    res = Tyrant::ChangePassword.({ email: "change@trb.org", 
                                    password: "123123", 
                                    new_password: "NewPassword", 
                                    confirm_new_password: "NewPassword"},
                                   "current_user" => user["model"])

    res.success?.must_equal true
    res["model"].email.must_equal "change@trb.org"

    assert Tyrant::Authenticatable.new(res["model"]).digest != "123123"
    assert Tyrant::Authenticatable.new(res["model"]).digest == "NewPassword"
    Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
    Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false
  end
end

