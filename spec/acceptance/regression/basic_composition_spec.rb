require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "basic object composition" do
  subject { new_object_context }

  before do
    append_test_load_path "basic_composition"
    require 'fence'
    require 'wood'
    require 'nails'
  end

  after do
    restore_load_path
  end

  it "constructs objects by providing necessary object components" do
    fence = subject.get('fence')
    fence.should_not be_nil
    fence.send(:object_context).should == subject

    fence.wood.should_not be_nil
    fence.wood.object_id.should == subject.get('wood').object_id
    fence.wood.send(:object_context).should == subject

    fence.nails.should_not be_nil
    fence.nails.object_id.should == subject.get('nails').object_id
    fence.nails.send(:object_context).should == subject
  end

end

