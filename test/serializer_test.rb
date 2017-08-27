require "test_helper"

class SerializerTest < MiniTest::Spec

  describe "Record as persistent Model" do
    it "test" do
      res = Tyrant::SignUp.({ email: "selectport@trb.to", password: "123123" })

      assert Tyrant::Serializer.new(res["model"]).serialize_into == {:model=>"User", :id=>res["model"].id}
      Tyrant::Serializer.new({"model"=>"User", "id"=>res["model"].id}).serialize_from.must_equal User.find(res["model"].id)
    end
  end

  describe "Record as not persistent Model" do
    it "test" do
      res = OpenStruct.new({email: "tyrant@trb.to", url: 'https://api.github.com/user', access_token: "access_token"})

      WebMock.disable!
      assert Tyrant::Serializer.new(res).serialize_into == {:url=>'https://api.github.com/user', :access_token=>"access_token"}
      assert_nil Tyrant::Serializer.new(res).serialize_from # FIX ME: test returning something
    end
  end
end
