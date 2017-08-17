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


    it { Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?(nil).must_equal false }
    it { Authenticatable.new(User.new({})).confirmable?("yo!").must_equal false }
    it { Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmable?("yo!").must_equal true }
    # TODO: add expiry.
  end

  describe "#confirmable!" do
    it do
      auth = Authenticatable.new(User.new)
      auth.confirmable?.must_equal false
      auth.confirmable!.must_equal auth
      auth.confirmable?.must_equal true
      auth.auth_meta_data.confirmation_token.must_be_kind_of String
    end
  end

  describe "#confirmed? / #cofirmed!" do
    # blank.
    it { Authenticatable.new(User.new).confirmed?.must_equal false }
    # with token.
    it { Authenticatable.new(User.new({confirmation_token: "yo!"})).confirmed?.must_equal false }

    it do
      auth = Authenticatable.new(User.new({confirmation_token: "yo!"}))
      auth.confirmed!
      # confirmed?
      auth.confirmed?.must_equal true
      # confirmed_at.
      auth.auth_meta_data.confirmed_at.must_be_kind_of DateTime
    end
  end

  describe "#confirmation_token" do
    it do
      auth = Authenticatable.new(User.new)
      auth.confirmation_token.must_equal nil
      auth.confirmable!
      auth.confirmation_token.must_be_kind_of String
    end
  end


  describe "#digest!" do
    it do
      auth = Authenticatable.new(User.new)
      auth.digest.must_equal nil
      auth.digest!("secret: Trailblazer rules!")
      assert auth.digest == "secret: Trailblazer rules!"
      auth.digest.must_be_instance_of BCrypt::Password

      # TODO: sync must be called!
    end
  end

  describe "#digest?" do
    it do
      auth = Authenticatable.new(User.new)
      auth.digest?("secret: Trailblazer rules!").must_equal false

      auth.digest!("secret: Trailblazer rules!")
      auth.digest?("secret: Trailblazer sucksssss!").must_equal false
      auth.digest?("secret: Trailblazer rules!").must_equal true
    end
  end

  describe '#digest_reset_password!' do
    it do
      auth = Authenticatable.new(User.new)
      auth.auth_meta_data.reset_password_token.must_equal nil
      auth.auth_meta_data.reset_password_expire_at.must_equal nil

      auth.digest_reset_password!("secret: TRB reset password!", "now + 1 hour")
      auth.auth_meta_data.reset_password_token.must_equal "secret: TRB reset password!"
      auth.auth_meta_data.reset_password_expire_at.must_equal "now + 1 hour"
   end
  end

  describe '#digest_reset_password?' do
    it do
      auth = Authenticatable.new(User.new)
      auth.digest_reset_password!("secret: TRB reset password!")

      auth.digest_reset_password?("secret: TRB reset password!").must_equal true
    end
  end

  describe '#reset_password_expired?' do
    it do
      auth = Authenticatable.new(User.new)
      auth.digest_reset_password!("secret: TRB reset password!")
      auth.digest_reset_password?("secret: TRB reset password!").must_equal true

      # not expired
      auth.reset_password_expired?.must_equal false

      # test if expires
      auth.digest_reset_password!("secret: TRB reset password!", DateTime.now - 1.minute)
      auth.reset_password_expired?.must_equal true
    end
  end
end
