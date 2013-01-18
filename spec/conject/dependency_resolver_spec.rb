require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Conject::DependencyResolver do

  subject { described_class.new(:class_finder => class_finder) }

  class StubbedObjectContext
    attr_accessor :objects
    def initialize(objects)
      @objects = objects
    end
    def get(name)
      @objects[name]
    end
  end

  let :klass do
    Class.new do
      construct_with :cow, :dog
    end
  end

  let :oc_objects do { cow: "the cow", dog: "the dog" } end

  let :object_context do StubbedObjectContext.new(oc_objects) end

  let :class_finder do mock("class finder") end

  before do
    class_finder.stub(:get_module_path)
  end

  it "maps the object definition component names of the given class to a set of objects gotten from the object context" do
    subject.resolve_for_class(klass, object_context).should == {
      cow: "the cow",
      dog: "the dog"
    }
  end

  describe "when the class is in a module" do
    before do
      class_finder.stub(:get_module_path).with(klass).and_return("a/module/path")
      object_context.stub(:get).with("a/module/path/cow").and_return "the relative cow"
      object_context.stub(:get).with("a/module/path/dog").and_return "the relative dog"
    end

    it "first tries to lookup relative component names" do
      subject.resolve_for_class(klass, object_context).should == {
        cow: "the relative cow",
        dog: "the relative dog",
      }
    end


  end
end

