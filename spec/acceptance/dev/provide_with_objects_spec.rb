require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "lazy dependency resolution via provide_with_objects" do
  subject { new_object_context }

  before do
    append_test_load_path "lazy_resolution"
    require 'hobbit/baggins'
    require 'hobbit/shire'
    require 'hobbit/precious'
    require 'hobbit/smeagol'
  end

  after do
    restore_load_path
  end

  describe "for 'regular' context objects (instances)" do
    it "provides objects" do
      baggins = subject["hobbit/baggins"]
      baggins.to_s.should == "From the Shire, found the One Ring"
    end

    it "includes both the convenient, short-hand object name in addition to the canonical" do
      baggins = subject["hobbit/baggins"]
      baggins.send(:shire).to_s.should == "Shire"
      baggins.send(:hobbit_shire).to_s.should == "Shire"
      baggins.send(:precious).to_s.should == "One Ring"
      baggins.send(:hobbit_precious).to_s.should == "One Ring"
    end

    it "can use deps inside #initialize" do
      gollum = subject["hobbit/smeagol"]
      gollum.saying.should == "They stole it from us, precious One Ring"
    end
  end

  describe "mixed lazy and construct with"
  describe "provide SELF with objects"
  describe "objects injected into context after construction"
  describe "module-relative dep names"

end

