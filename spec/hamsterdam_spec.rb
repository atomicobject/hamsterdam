require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Hamsterdam structures" do
  def define_hamsterdam_struct(*field_names)
    Hamsterdam::Struct.define(*field_names)
  end

  let(:struct_class) { define_hamsterdam_struct(:top, :bottom) }

  describe "Struct.define" do

    it "creates a structure class based on the given fields" do
      struct = struct_class.new(top: 200, bottom: "all the way down")
      struct.should be
      struct.top.should == 200
      struct.bottom.should == "all the way down"
    end

    it "can be built with underlying persistent data structure hashes hashes" do
      struct = struct_class.new(Hamsterdam.from_ruby_hash(top: 10, bottom: "low"))
      struct.should be
      struct.top.should == 10
      struct.bottom.should == "low"
    end

    it "does not accept constructor inputs that are not defined" do
      lambda do struct_class.new(oops: ":)", wups: ":(") end.should raise_error(/oops/)
    end

    it "allows omission of keys" do
      struct = struct_class.new(top: 50)
      struct.top.should == 50
      struct.bottom.should be_nil
    end

    it "allows omission of all keys" do
      struct = struct_class.new
      struct.top.should be_nil
      struct.bottom.should be_nil
    end

    it "provides access to the internal data as the correct hash type" do
      s1 = struct_class.new(top: 50, bottom: 75)
      s1.internal_hash.should == Hamsterdam.from_ruby_hash(top: 50, bottom: 75)
    end

    it "raises helpful error when constructed with invalid objects" do
      lambda do struct_class.new("LAWDY") end.should raise_error /Do not want.*LAWDY/
    end

    describe "inheritance-based definition" do
      class Castle < Hamsterdam::Struct(:gate, :mote, :walls)
        def tally
          gate + mote + walls
        end
      end

      it "provides convenient syntax for deriving classes from immutable struct def" do
        c = Castle.new gate: 2, mote: 1, walls: 4
        c.gate.should == 2
        c.mote.should == 1
        c.walls.should == 4
        c.tally.should == 7
      end
    end
  end

  describe "equality" do
    it "considers two structs equal if they have the same field values" do
      s1 = struct_class.new(top: 50, bottom: 75)
      s2 = struct_class.new(top: 50, bottom: 75)
      s1.eql?(s2).should == true
      (s1 == s2).should == true
      s1.should == s2
    end

    it "considers two structs NOT equal if they have the different field values" do
      s1 = struct_class.new(top: 50, bottom: 75)
      s2 = struct_class.new(top: 50, bottom: 74)
      s3 = struct_class.new(top: 51, bottom: 75)

      s1.eql?(s2).should_not == true
      (s1 == s2).should_not == true
      s1.should_not == s2

      s1.eql?(s3).should_not == true
      (s1 == s3).should_not == true
      s1.should_not == s3
    end

    it "doesn't consider to structs eql? unless they are same class" do
      s1 = struct_class.new(top: 50, bottom: 75)
      s2 = define_hamsterdam_struct(:top, :bottom).new(top:50, bottom:75)
      s1.eql?(s2).should == false
      (s1 == s2).should == true # should still be ==
    end

    it "considers equal two structs if one has missing keys, and the other has nil values for those keys" do
      s1 = struct_class.new(top: 50, bottom: nil)
      s2 = struct_class.new(top: 50)
      # binding.pry
      s1.eql?(s2).should == true
      (s1 == s2).should == true
      s1.should == s2
    end
  end

  it "uses the same #hash as the underlying data structure" do
    s1 = struct_class.new(top: 50, bottom: 75)
    s1.hash.should == Hamsterdam.from_ruby_hash(top:50, bottom:75).hash
  end

  describe "transformation" do
    it "provides setters for individual fields that return an updated version of the struct" do
      struct = struct_class.new(top: 10, bottom: 1)
      struct2 = struct.set_top("woot")
      struct2.top.should == "woot"
      struct2.bottom.should == 1

      struct.top.should == 10
      struct.bottom.should == 1
    end

    it "returns the same struct if a set does not change the value" do
      struct = struct_class.new(top: 25, bottom: 2)
      struct.set_top(25).set_bottom(2).should equal(struct)
    end

    it "provides a merge function" do
      struct = struct_class.new(top: 10, bottom: 1)

      struct2 = struct.merge(bottom: "new")
      struct2.top.should == 10
      struct2.bottom.should == "new"

      struct.top.should == 10
      struct.bottom.should == 1

      struct3 = struct2.merge(top: "newer", bottom: "very")
      struct3.top.should == "newer"
      struct3.bottom.should == "very"
    end

    it "can merge-in a non-ruby hash" do
      struct = struct_class.new(top: 10, bottom: 1)

      struct2 = struct.merge(Hamsterdam.from_ruby_hash(bottom: "newer", top: "newest"))
      struct2.top.should == "newest"
      struct2.bottom.should == "newer"

      struct.top.should == 10
      struct.bottom.should == 1
    end

  end

  describe "inspect and to_s" do
    module Hamstest
      Wheel = Hamsterdam::Struct.define(:x,:y,:radius,:label)
      Vehicle = Hamsterdam::Struct.define(:wheels, :body_style)
      Thinger = Hamsterdam::Struct.define(:a_hash, :a_set, :a_list)
    end


    it "generates a nice clear string representation of the internal data" do
      wheel = Hamstest::Wheel.new x: 50, y: 100, radius: 5.0, label: "front"
      expected = "<Wheel x: 50 y: 100 radius: 5.0 label: \"front\">"
      wheel.inspect.should == expected
      wheel.to_s.should == expected
    end

    it "does a nice job with other Hamsterdam structs" do
      wheel1 = Hamstest::Wheel.new x: 50, y: 100, radius: 5.0, label: "front"
      wheel2 = Hamstest::Wheel.new x: 100, y: 100, radius: 5.0, label: "back"
      car = Hamstest::Vehicle.new wheels: Hamster.list(wheel1, wheel2), body_style: "sedan"
      expected = "<Vehicle wheels: [<Wheel x: 50 y: 100 radius: 5.0 label: \"front\">, <Wheel x: 100 y: 100 radius: 5.0 label: \"back\">] body_style: \"sedan\">"
      car.inspect.should == expected
      car.to_s.should == expected
    end

    it "does a nice job with Hamster Lists, Sets, and Hashes" do
      thinger = Hamstest::Thinger.new a_hash: Hamster.hash(red: "fish"), a_set: Hamster.set(42), a_list: Hamster.list(:oh, :the, :things)
      expected = "<Thinger a_hash: {:red => \"fish\"} a_set: {42} a_list: [:oh, :the, :things]>"
      thinger.inspect.should == expected
      thinger.to_s.should == expected
    end
  end

  describe "symbol/string insensitivity" do
    let(:mixed_up) { Hamsterdam::Struct.define(:foo, 'bar') }

    it "lets you define the field names using a mix of string and symbols" do
      val = mixed_up.new(foo: 1, bar: 2)
      val.foo.should == 1
      val.bar.should == 2
      val = val.set_foo(3)
      val.foo.should == 3
    end

    it "lets you construct new values using a mix of strings and symbols" do
      val = mixed_up.new("foo" => 1, :bar => 2)
      val.foo.should == 1
      val.bar.should == 2
    end

    it "lets you merge values using a mix of strings and symbols" do
      val = mixed_up.new("foo" => 1, :bar => 2)
      val.foo.should == 1
      val.bar.should == 2
      val = val.merge(:foo => 3, "bar" => 4)
      val.foo.should == 3
      val.bar.should == 4

      val.internal_hash.should == Hamsterdam.from_ruby_hash(foo: 3, bar: 4)
    end
  end
end
