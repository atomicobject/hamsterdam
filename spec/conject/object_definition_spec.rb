require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Conject::ObjectDefinition do
  def new_def(*args)
    Conject::ObjectDefinition.new(*args)
  end

  it "has a field for :component_names and :owner and can be built with them" do
    subject = new_def :owner => "the owner", :component_names => [ :one, :two ]
    subject.owner.should == "the owner"
    subject.component_names.should == [:one, :two]
  end

  it "defaults :component_names to an empty array" do
    subject = new_def :owner => "the owner"
    subject.owner.should == "the owner"
    subject.component_names.should be_empty
  end

  it "defaults :owner to nil" do
    subject = new_def :component_names => [ :one, :two ]
    subject.owner.should nil
    subject.component_names.should == [:one, :two]
  end

  it "can be built with no args" do
    subject = new_def
    subject.owner.should nil
    subject.component_names.should be_empty
  end
end
