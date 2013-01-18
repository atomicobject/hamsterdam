require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "configuring objects to be non-cacheable" do
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

  it "causes an object to be rebuilt with every request" do
    subject.configure_objects(
      :fence => { :cache => false }, 
      :nails => { :cache => false },
    )

    f1 = subject.get(:fence)
    f2 = subject.get(:fence)

    # Show new fences built:
    f1.should be
    f2.should be
    f1.should_not == f2

    # nails should also be unique:
    f1.nails.should_not == f2.nails

    # wood should remain cached as usual, and shared
    f1.wood.should == f2.wood
    subject.has?(:wood).should == true
    subject.get(:wood).should == f1.wood
    subject.get(:wood).should == f2.wood
  end

end

#
# other syntax ideas:
#
    # subject.no_cache(:fence)

    # subject.do_not_cache(:fence)

    # subject.configure(:fence, :cache => false)

    # subject.configure(:fence, :singleton => false)

    # subject.configure do |config|
    #   config.object :fence, :cache => false
    # end

    # subject.configure.object :fence, :cache => false
