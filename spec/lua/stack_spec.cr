require "../spec_helper"

module Lua
  describe Stack do
    describe "#<<" do
      it "can push nil value" do
        Stack.new.tap(&.<< nil)[1].should eq nil
      end

      it "can push int value" do
        Stack.new.tap(&.<< 10)[1].should eq 10.0
      end

      it "can push float value" do
        Stack.new.tap(&.<< 42.0)[1].should eq 42.0
      end

      it "can push bool true value" do
        Stack.new.tap(&.<< true)[1].should eq true
      end

      it "can push bool false value" do
        Stack.new.tap(&.<< false)[1].should eq false
      end

      it "can push char value" do
        Stack.new.tap(&.<< 'x')[1].should eq "x"
      end

      it "can push string value" do
        Stack.new.tap(&.<< "message")[1].should eq "message"
      end

      it "can push symbol value" do
        Stack.new.tap(&.<< :message)[1].should eq "message"
      end

      it "can push array" do
        r = Stack.new.tap(&.<< %w(lua is cool))[1].as(Table).map { |k, v| v }
        r.should eq %w(lua is cool)
      end

      it "can push hash" do
        r = Stack.new.tap(&.<< ({"one": '1', "two": '2'}))[1].as(Table).map { |k, v| {k.as(String), v} }
        r.sort_by(&.[0]).should eq [{"one", "1"}, {"two", "2"}]
      end

      it "can push tuple" do
        r = Stack.new.tap(&.<<({:one, :two, :three}))[1].as(Table).map { |k, v| v }
        r.should eq %w(one two three)
      end

      it "can push named tuple" do
        r = Stack.new.tap(&.<<({one: '1', two: '2', three: '3'}))[1].as(Table).map { |k, v| v.as(String) }
        r.sort.should eq %w(1 2 3)
      end

      it "can push inner array" do
        r = Stack.new.tap(&.<<({"inner" => [1, 2, 3]}))[1].as(Table)["inner"].as(Table).map { |k, v| v.as(Float) }
        r.sort.should eq [1, 2, 3]
      end

      it "raises error when it is a wrong object" do
        s = Stack.new
        expect_raises { s << Exception.new }
      end

      it "accepts custom object that responds to :to_lua" do
        obj = LuaReporter.new("Hello lua")
        Stack.new.tap(&.<< obj)[1].should eq "Hello lua"
      end
    end

    describe "#[]" do
      it "returns first element for -1" do
        Stack.new.tap(&.<< :whew)[-1].should eq "whew"
      end

      it "returns nil for 0" do
        Stack.new[0].should eq nil
      end
    end

    describe "#to_s" do
      it "represents the stack as a string" do
        stack = Lua::Stack.new.tap do |s|
          s << 42.24
          s << false
          s << "hello!"
        end
        stack.to_s.should eq "3 : TSTRING(string) hello!\n2 : TBOOLEAN(boolean) false\n1 : TNUMBER(number) 42.24"
      end
    end

    describe "#size" do
      it "returns the index of the top element" do
        Stack.new.tap do |s|
          s << 3
          s << :times
          s << :faster
        end.size.should eq 3
      end

      it "returns 0 when stack is empty" do
        Stack.new.size.should eq 0
      end
    end

    describe "#pop" do
      it "returns the element from the top of the stack" do
        Stack.new.tap(&.<< 10.01).pop.should eq 10.01
      end

      it "removes the element from the top of the stack" do
        Stack.new.tap(&.<< 10.01).tap(&.pop).size.should eq 0
      end

      it "returns nil when stack is empty" do
        Stack.new.pop.should eq nil
      end
    end

    describe "#type_at" do
      it "can return TNIL type" do
        Stack.new.tap(&.<< nil).type_at(1).should eq TYPE::TNIL
      end

      it "can return TBOOLEAN type" do
        Stack.new.tap(&.<< false).type_at(1).should eq TYPE::TBOOLEAN
      end

      it "can return TNUMBER type" do
        Stack.new.tap(&.<< 3).type_at(1).should eq TYPE::TNUMBER
      end

      it "can return TSTRING type" do
        Stack.new.tap(&.<< "s").type_at(1).should eq TYPE::TSTRING
      end
    end

    describe "#typename" do
      it "can return name of nil type" do
        Stack.new.tap(&.<< nil).typename(1).should eq "nil"
      end

      it "can return name of boolean type" do
        Stack.new.tap(&.<< false).typename(1).should eq "boolean"
      end

      it "can return name of number type" do
        Stack.new.tap(&.<< 3).typename(1).should eq "number"
      end

      it "can return name of string type" do
        Stack.new.tap(&.<< "s").typename(1).should eq "string"
      end
    end
  end
end