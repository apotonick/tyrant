require "test_helper"

class SessionTest < MiniTest::Spec
  it do
    session = Tyrant::Session.new(warden)

    session.current_user.must_equal nil
    assert ! session.signed_in?

    session.sign_in!(Object)

    session.current_user.must_equal Object
    assert session.signed_in?

    session.sign_out!

    session.current_user.must_equal nil
    assert ! session.signed_in?
  end
end
