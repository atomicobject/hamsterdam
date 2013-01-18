require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")


describe Conject::CompositionError do
  subject do 
    described_class.new construction_args
  end

  before do
    append_test_load_path "simple_stuff"
    require 'some_random_class'
  end

  after do
    restore_load_path
  end

  let :construction_args do
    {
      :object_definition => object_definition, 
      :provided => []
    }
  end

  let :object_definition do
    Conject::ObjectDefinition.new(
      :owner => SomeRandomClass,
      :component_names => []
    )
  end

  describe "when missing one required component" do
    before { object_definition.component_names << :an_object }
    
    it "indicates the missing object" do
      subject.message.should == "Wrong components when building new SomeRandomClass. Missing required object(s) [:an_object]."
    end
  end

  describe "when missing multiple required components" do
    before do
      object_definition.component_names << :an_object
      object_definition.component_names << :another_object
    end

    it "indicates all missing objects" do
      subject.message.should == "Wrong components when building new SomeRandomClass. Missing required object(s) [:an_object, :another_object]."
    end
  end

  describe "when an unexpected component is provided" do
    before { construction_args[:provided] = [ :surprise ] }

    it "calls out the unexpected object" do
      subject.message.should == "Wrong components when building new SomeRandomClass. Unexpected object(s) provided [:surprise]."
    end
  end

  describe "when multiple unexpected components are provided" do
    before { construction_args[:provided] = [ :surprise, :hello ] }
    it "calls out all unexpected objects" do
      subject.message.should == "Wrong components when building new SomeRandomClass. Unexpected object(s) provided [:surprise, :hello]."
    end
  end

  describe "when unexpected components are provided AND required components are missing" do
    before do
      object_definition.component_names << :part_one
      object_definition.component_names << :part_two
      object_definition.component_names << :part_three
      construction_args[:provided] = [ :part_two, :surprise_one, :surprise_two ]
    end

    it "generates a message for both missing AND unexpected components" do
      subject.message.should == "Wrong components when building new SomeRandomClass. Missing required object(s) [:part_one, :part_three]. Unexpected object(s) provided [:surprise_one, :surprise_two]."
    end
  end

  describe "without object_definition" do
    it "has a vague message" do
      construction_args.delete :object_definition
      construction_args[:provided] = [ :one, :two ]
      subject.message.should == "Failed to construct... something. Provided objects were: [:one, :two]"
    end
  end

  describe "with nil construction args" do
    let :construction_args do nil end

    it "has a vague message" do
      subject.message.should == "Failed to construct... something."
    end
  end

  describe "without any args supplied at all" do
    let :construction_args do nil end
    it "has a vague message" do
      described_class.new.message.should == "Failed to construct... something."
    end
  end

  describe "without an object_definition.owner" do
    let :object_definition do
      Conject::ObjectDefinition.new(
        :component_names => [:a, :b]
        # no owner
      )
    end

    it "uses a placeholder name, but otherwise generates good info" do
      subject.message.should == "Wrong components when building new object. Missing required object(s) [:a, :b]."
    end
  end

  describe "without provided object names" do
    it "indicates which components are required but not what's missing" do
      object_definition.component_names << :wanting
      construction_args.delete :provided
      # p object_definition
      subject.message.should == "Wrong components when building new SomeRandomClass. Missing required object(s) [:wanting]."
    end
  end

end
