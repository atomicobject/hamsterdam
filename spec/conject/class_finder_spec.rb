require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Conject::ClassFinder do
  describe "#find_class" do
    before do
      append_test_load_path "simple_stuff"
      append_test_load_path "namespace"
      require 'some_random_class'
      require 'chart/model'
      require 'somewhere/deep/inside/the/earth'
    end

    after do
      restore_load_path
    end

    it "returns the class implied by the given name" do
      c = subject.find_class('some_random_class')
      c.should_not be_nil
      c.should == SomeRandomClass
    end

    it "can accept symbols for object names" do
      c = subject.find_class(:some_random_class)
      c.should_not be_nil
      c.should == SomeRandomClass
    end

    it "raises an error if the name doesn't imply a regular class in the current runtime" do
      lambda do
        subject.find_class('something_undefined')
      end.should raise_error(/could not find class.*SomethingUndefined/i)
    end

    it "raises an error for nil input" do
      lambda do
        subject.find_class('something_undefined')
      end.should raise_error(/could not find class.*SomethingUndefined/i)
    end

    context "namespaced" do
      it "can find namespaced classes for objects with / in name" do
        c = subject.find_class("chart/model")
        c.should_not be_nil
        c.should == Chart::Model
      end

      it "can find deeply namespaced classes for objects with / in name" do
        c = subject.find_class("somewhere/deep/inside/the/earth")
        c.should_not be_nil
        c.should == Somewhere::Deep::Inside::The::Earth
      end

      it "raises an error for a misstep along the way" do
        lambda do
          subject.find_class("somewhere/deep/above/the/earth")
        end.should raise_error(/could not find.*Above within Somewhere::Deep/i)
      end
    end
  end

  describe "#get_module_path" do
    before do
      append_test_load_path "namespace"
      require 'deeply_nested/ez_chart/presenter'
    end

    it "returns nil if given class doesn't have :: symbols in it" do
      subject.get_module_path(Object).should be_nil
    end

    it "returns the underscored pathname of the module for the given class" do
      subject.get_module_path(Conject::ObjectContext).should == "conject"
      subject.get_module_path(DeeplyNested::EzChart::Presenter).should == "deeply_nested/ez_chart"
    end
  end
end
