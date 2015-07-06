require "test_helper"

class AuthenticatableTest < MiniTest::Spec
  Authenticatable = Tyrant::Authenticatable
  User = Struct.new(:auth_meta_data)

  describe "#confirmable?" do
    # nothing initialized.
    it { Authenticatable.new(User.new).confirmable?.must_equal false }
    it { Authenticatable.new(User.new({})).confirmable?.must_equal false }
    it { Authenticatable.new(User.new({confirmation_token: nil})).confirmable?.must_equal false }
    # token given.
    it { Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?.must_equal true }


    it { Authenticatable.new(User.new({})).confirmable?("yo!").must_equal false }
    it { Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?("yo!").must_equal true }
    # TODO: add expiry.
  end

  describe "#confirmed?" do
    # blank.
    it { Authenticatable.new(User.new).confirmed?.must_equal false }
    # with token.
    it { Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmed?.must_equal false }

    it do
      auth = Authenticatable.new(User.new({confirmation_token: "yo!"}))
      auth.confirm!
      # confirmed?
      auth.confirmed?.must_equal true
      # confirmed_at.
      auth.auth_meta_data.confirmed_at.must_be_kind_of DateTime
    end
  end
end