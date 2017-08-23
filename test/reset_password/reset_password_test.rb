require "test_helper"

class ResetPasswordTest < MiniTest::Spec

  describe 'Reset::Password::Request' do

    it 'fail reset password request' do
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

      res = Tyrant::ResetPassword::Request.({email: "wrong@trb.org"})

      res.failure?.must_equal true
      res["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"User not found\"]}"
    end

    it 'successfully reset password request' do
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

      safe_url = -> { "safe_url" }

      num_emails = Mail::TestMailer.deliveries.length
      res = Tyrant::ResetPassword::Request.({email: "reset@trb.org"}, "generator" => safe_url, "via" => :test, "url" => "confirm_password_url")

      res.success?.must_equal true
      res["model"].email.must_equal "reset@trb.org"
      res["reset_link"].must_equal "confirm_password_url?safe_url=safe_url&email=reset%40trb.org"

      # the password is not touched yet (user hasn't clicked the link)
      assert Tyrant::Authenticatable.new(res["model"]).digest == "123123"
      Tyrant::Authenticatable.new(res["model"]).confirmed?.must_equal true
      Tyrant::Authenticatable.new(res["model"]).confirmable?.must_equal false
      # reset password token set
      Tyrant::Authenticatable.new(res["model"]).digest_reset_password?("safe_url").must_equal true

      Mail::TestMailer.deliveries.length.must_equal num_emails+1
      Mail::TestMailer.deliveries.last.to.must_equal ["reset@trb.org"]
    end
  end

  describe 'Reset::Passwor::Confirm' do

    it "fail confirm reset password" do
      res = Tyrant::SignUp::Confirmed.(
        email: "reset@trb.org",
        password: "123123",
        confirm_password: "123123",
      )

      res.success?.must_equal true
      res["model"].email.must_equal "reset@trb.org"

      result = Tyrant::ResetPassword::Confirm.({})
      result["result.contract.default"].errors.messages.inspect.must_equal "{:email=>[\"must be filled\"], :safe_url=>[\"must be filled\", \"Something went wrong please try to reset the password again\", \"Link expired\"], :new_password=>[\"must be filled\", \"Passwords are not matching\"], :confirm_new_password=>[\"must be filled\", \"Passwords are not matching\"]}"
    end

    it "successfully confirm reset password" do
      res = Tyrant::SignUp::Confirmed.(
        email: "reset@trb.org",
        password: "123123",
        confirm_password: "123123",
      )

      res.success?.must_equal true
      res["model"].email.must_equal "reset@trb.org"

      safe_url = -> { "safe_url" }
      res = Tyrant::ResetPassword::Request.({email: "reset@trb.org"}, "generator" => safe_url, "via" => :test, "url" => "confirm_password_url")
      res.success?.must_equal true

      result = Tyrant::ResetPassword::Confirm.({email: "reset@trb.org", safe_url: "safe_url", new_password: "newpassword", confirm_new_password: "newpassword"})
      result.success?.must_equal true
      result["model"].email.must_equal "reset@trb.org"

      assert Tyrant::Authenticatable.new(result["model"]).digest != "123123"
      assert Tyrant::Authenticatable.new(result["model"]).digest == "newpassword"
      Tyrant::Authenticatable.new(result["model"]).confirmed?.must_equal true
      Tyrant::Authenticatable.new(result["model"]).confirmable?.must_equal false
      # reset link set to expired after save new password
      Tyrant::Authenticatable.new(result["model"]).reset_password_expired?.must_equal true
    end
  end
end

