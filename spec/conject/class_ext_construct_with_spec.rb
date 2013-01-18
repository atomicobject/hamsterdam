require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "Class" do

  describe ".construct_with" do
    subject do
      Class.new do
        construct_with :object1, :object2

        def initialize
          @saw = "initialize has access to #{object1} and #{object2}"
        end

        def explain
          "Made of #{object1} and #{object2}"
        end

        def to_s
          @saw
        end
      end
    end

    it "lets you construct instances with sets of named objects" do
      instance = subject.new :object1 => "first object", :object2 => "second object"
      instance.explain.should == "Made of first object and second object"
    end

    it "sets objects before initialize is invoked" do
      instance = subject.new :object1 => "one", :object2 => "two"
      instance.to_s.should == "initialize has access to one and two"
    end

    it "defines the object accessors as private" do
      instance = subject.new :object1 => "one", :object2 => "two"
      lambda do instance.object1 end.should raise_error(NoMethodError)
      lambda do instance.object2 end.should raise_error(NoMethodError)
    end

    describe "when user defines initialize with one argument" do
      subject do
        Class.new do
          construct_with :ant, :aardvark

          attr_reader :map_string, :also

          def initialize(map)
            @map_string = map.inspect
            @also = "Preset #{ant} and #{aardvark}"
          end
        end
      end

      let :map do { :ant => "red", :aardvark => "blue" } end

      it "passes along the object map" do
        subject.new(map).map_string.should == map.inspect
      end

      it "still pre-sets the object accessors" do
        subject.new(map).also.should == "Preset red and blue"
      end
    end

    describe "when user defines initialize with var args" do
      subject do
        Class.new do
          construct_with :ant, :aardvark

          attr_reader :map_string, :also

          def initialize(*stuff)
            map = stuff.shift
            @map_string = map.inspect
            @also = "Preset #{ant} and #{aardvark}"
          end
        end
      end

      let :map do { :ant => "red", :aardvark => "blue" } end

      it "passes along the object map" do
        subject.new(map).map_string.should == map.inspect
      end

      it "still pre-sets the object accessors" do
        subject.new(map).also.should == "Preset red and blue"
      end
    end

    describe "when user defines initialize with too many args" do
      subject do
        Class.new do
          construct_with :beevis, :butthead
          def initialize(one,two)
            # won't ever get run because the .new override will freak due to our arity
          end
        end
      end

      let :map do { :beevis => "nh nh!", :butthead => "uhhh huh huh" } end

      it "raises an error due to invalid #initialize signature" do
        lambda do subject.new(map) end.should raise_error(RuntimeError, /initialize method defined with 2 parameters/) 
      end
    end

    describe "when user doesn't define an initialize" do
      subject do
        Class.new do
          construct_with :something
          def to_s
            "Something is #{something}"
          end
        end
      end

      it "works normally" do
        subject.new(:something => "normal").to_s.should == "Something is normal"
      end
    end

    describe "when no object map is supplied to constructor" do
      it "raises a typical argument error" do
        lambda do subject.new end.should raise_error(ArgumentError)
      end
    end

    describe "when object map does not contain any required objects" do
      it "raises a composition error explaining missing objects" do
        lambda do subject.new({}) end.should raise_error(
          Conject::CompositionError, 
          /missing required.*object1.*object2/i
        )
      end
    end

    describe "when object map contains only SOME of the required objects" do
      it "raises a composition error explaining which missing objects" do
        lambda do subject.new(:object2 => "ok") end.should raise_error(
          Conject::CompositionError, 
          /missing required.*object1/i
        )
      end
    end

    describe "when object map contains objects that are not accepted" do
      it "raises a composition error explaining rejected objects" do
        lambda do 
          subject.new(
            :object1 => "ok",
            :object2 => "ok",
            :not_even_supposed => "to be here", 
            :stop => "whining"
          ) 
        end.should raise_error(
          Conject::CompositionError, 
          /unexpected object.*not_even_supposed.*stop/i
        )
      end
    end

    describe "when object map has a mix of missing and unexpected objects" do
      it "raises a composition error explaining missing and rejected objects" do
        lambda do 
          subject.new(
            :object1 => "ok",
            :not_even_supposed => "to be here"
          )
        end.should raise_error(
          Conject::CompositionError, 
          /missing required.*object2.*unexpected object.*not_even_supposed/i
        )
      end
    end

  end

  describe ".object_definition" do
    subject do 
      Class.new do
        construct_with :cats, :dogs
      end
    end

    it "exists on classes that use construct_with" do
      subject.should respond_to(:object_definition)
    end

    it "references the owning class" do
      subject.object_definition.owner.should == subject
    end

    it "contains the list of required object names for construction of new instances" do
      subject.object_definition.component_names.to_set.should == [:cats,:dogs].to_set
    end

    describe "for classes that don't use construct_with" do

      before do
        append_test_load_path "simple_stuff"
        require 'some_random_class'
      end

      after do
        restore_load_path
      end

      it "doesn't exist" do
        require 'some_random_class'
        SomeRandomClass.should_not respond_to(:object_definition)
      end
    end
  end

  describe ".has_object_definition?" do
    it "returns false for all regular classes" do
      Class.new.has_object_definition?.should be_false
    end

    it "returns true for classes that use construct_with" do
      Class.new do construct_with :a end.has_object_definition?.should be_true
    end
  end

end
