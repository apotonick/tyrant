require "test_helper"

class SessionTest < MiniTest::Spec
  class FakeWarden
    attr_accessor :user
    # TODO: replace with real warden.
    alias_method :set_user, :user=
    def logout
      @user = nil
    end
  end

  let (:warden) { FakeWarden.new }

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