require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "Conject" do
  before do
    append_test_load_path "basic_composition"
    require 'fence'
    require 'wood'
    require 'nails'
  end

  describe ".default_object_context" do
    it "provides an object context" do
      context = Conject.default_object_context
      context[:fence].should be
    end


    it "provides the SAME object context on repeated use" do
      context1 = Conject.default_object_context
      context2 = Conject.default_object_context

      context1.should be
      context1.should == context2
      context1[:fence].should == context2[:fence]
    end
    
  end

  after do
    restore_load_path
    # Sneak in and reset default object context instance inside Conject:
    Conject.instance_variable_set(:@default_object_context, nil)
  end

end

