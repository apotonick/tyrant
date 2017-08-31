require "test_helper"

class SerializerTest < MiniTest::Spec

  describe "Record as persistent Model" do
    it "test" do
      # I need to confirm this to make sure that the test will pass
      Tyrant::Serializer.class_eval do
        def serialize_into
          model_into
        end

        def serialize_from
          model_from
        end
      end

      res = Tyrant::SignUp.({ email: "selectport@trb.to", password: "123123" })
      res.success?.must_equal true

      assert Tyrant::Serializer.new(res["model"]).serialize_into == {:model=>"User", :id=>res["model"].id}
      Tyrant::Serializer.new({"model"=>"User", "id"=>res["model"].id}).serialize_from.must_equal User.find(res["model"].id)
    end

    it "test using custom methods" do

      Tyrant::Serializer.class_eval do
        def serialize_into
          {model: @record.class.name, email: @record.email}
        end

        def serialize_from
          @record['model'].constantize.where("email like ?", @record['email'])
        end
      end

      res = Tyrant::SignUp.({ email: "selectport@trb.to", password: "123123" })

      assert Tyrant::Serializer.new(res["model"]).serialize_into == {:model=>'User', :email => 'selectport@trb.to'}
      Tyrant::Serializer.new({"model" => 'User', "email" => res["model"].email}).serialize_from.must_equal User.where("email like ?", res["model"].email)
    end
  end

  describe "Record as not persistent Model" do
    it "test using provided methods" do
      Tyrant::Serializer.class_eval do
        def serialize_into
          url_into
        end

        def serialize_from
          url_from
        end
      end

      res = OpenStruct.new({email: "tyrant@trb.to", url: 'https://api.github.com/user', access_token: "access_token"})

      WebMock.disable!
      assert Tyrant::Serializer.new(res).serialize_into == {:url=>'https://api.github.com/user', :access_token=>"access_token"}
      assert_nil Tyrant::Serializer.new(res).serialize_from # FIX ME: test returning something
    end
  end
end
