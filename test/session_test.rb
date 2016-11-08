require "test_helper"

class SessionTest < MiniTest::Spec
  it 'successfully create session without scope' do
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

  it 'successfully create session with scope' do
    session = Tyrant::Session.new(warden)

    session.current_user(scope: :user).must_equal nil
    assert ! session.signed_in?(scope: :user)

    session.sign_in!(Object, scope: :user)

    session.current_user(scope: :user).must_equal Object
    assert session.signed_in?(scope: :user)

    session.sign_out!(scope: :user)

    session.current_user(scope: :user).must_equal nil
    assert ! session.signed_in?(scope: :user)
  end

  it 'successfully create multiple sessions with scopes' do
    session = Tyrant::Session.new(warden)

    user = Object.new
    admin = Object.new

    session.current_user(scope: :user).must_equal nil
    assert ! session.signed_in?(scope: :user)
    session.current_user(scope: :admin).must_equal nil
    assert ! session.signed_in?(scope: :admin)

    session.sign_in!(user, scope: :user)
    session.sign_in!(admin, scope: :admin)

    session.current_user(scope: :user).must_equal user
    assert session.signed_in?(scope: :user)
    session.current_user(scope: :admin).must_equal admin
    assert session.signed_in?(scope: :admin)

    session.sign_out!(scope: :user)
    assert session.signed_in?(scope: :admin)
    session.current_user(scope: :user).must_equal nil
    assert ! session.signed_in?(scope: :user)

    session.sign_out!(scope: :admin)
    session.current_user(scope: :admin).must_equal nil
    assert ! session.signed_in?(scope: :admin)
  end

  describe "#sign_in!" do
    it 'passes through options to warden' do
      test_options = { store: false, scope: :admin }
      user = Object.new
      warden = Minitest::Mock.new
      warden.expect(:set_user, nil [user, test_options])

      session = Tyrant::Session.new(warden)
      session.sign_in!(user, test_options)

      warden.verify
    end
  end

  it 'sign out only default user if no scope specified' do
    session = Tyrant::Session.new(warden)

    user = Object.new
    default = Object.new

    session.sign_in!(user, scope: :user)
    session.sign_in!(default)

    session.sign_out!
    assert session.signed_in?(scope: :user)
    session.current_user.must_equal nil
    assert ! session.signed_in?
  end
end
