require "test_helper"

class MailerTest < MiniTest::Spec
  describe 'Mailer' do

    it "wrong input" do
      res = Tyrant::Mailer.()

      res.failure?.must_equal true
      res["contract.default"].errors.messages.inspect.must_equal "{:email=>[\"must be filled\"], :reset_link=>[\"must be filled\"]}"
    end

    it "successfully send email" do
      num_emails = Mail::TestMailer.deliveries.length

      res = Tyrant::Mailer.({email: "tyrant@trb.to", reset_link: "reset_link"}, "via" => :test)

      res.success?.must_equal true
      res["contract.default"].email.must_equal "tyrant@trb.to"
      res["contract.default"].reset_link.must_equal "reset_link"

      Mail::TestMailer.deliveries.length.must_equal num_emails += 1
      Mail::TestMailer.deliveries.last.to.must_equal ["tyrant@trb.to"]
    end

  end
end
