require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "Hamsterdam structures" do
  def define_hamsterdam_struct(*field_names)
    Hamsterdam::Struct.define(*field_names)
  end
  describe "Struct.define" do
    let(:struct_class) { define_hamsterdam_struct(:top, :bottom) }

    it "creates a structure class based on the given fields" do
      struct = struct_class.new(top: 200, bottom: "all the way down")
      struct.should be
      struct.top.should == 200
      struct.bottom.should == "all the way down"
    end

    it "can be built with Hamster hashes" do
      struct = struct_class.new(Hamster.hash(top: 10, bottom: "low"))
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

    it "provides access to the internal data as a Hamster.hash" do
      s1 = struct_class.new(top: 50, bottom: 75)
      s1.to_hamster_hash.should == Hamster.hash(top: 50, bottom: 75)
    end

    it "raises helpful error when constructed with invalid objects" do
      lambda do struct_class.new("LAWDY") end.should raise_error /Do not want.*LAWDY/
    end

    describe "equality" do
      it "considers two structs equal if they have the same field values" do
        s1 = struct_class.new(top: 50, bottom: 75)
        s2 = struct_class.new(top: 50, bottom: 75)
        s1.eql?(s2).should == true
        (s1 == s2).should == true
        s1.should == s2
      end

      it "doesn't consider to structs eql? unless they are same class" do
        s1 = struct_class.new(top: 50, bottom: 75)
        s2 = define_hamsterdam_struct(:top, :bottom).new(top:50, bottom:75)
        s1.eql?(s2).should == false
        (s1 == s2).should == true # should still be ==
      end
    end

    it "uses the same #hash as Hamster::Hash" do
      s1 = struct_class.new(top: 50, bottom: 75)
      s1.hash.should == Hamster.hash(top:50, bottom:75).hash
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

      it "can merge-in Hamster::Hash" do
        struct = struct_class.new(top: 10, bottom: 1)

        struct2 = struct.merge(Hamster.hash(bottom: "newer", top: "newest"))
        struct2.top.should == "newest"
        struct2.bottom.should == "newer"

        struct.top.should == 10
        struct.bottom.should == 1
      end
    end

  end
end
