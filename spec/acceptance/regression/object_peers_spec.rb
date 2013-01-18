require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "object_peers" do
  subject { new_object_context }

  before do
    append_test_load_path "object_peers"
    require 'game'
    require 'alt_game'
    require 'bullet'
    require 'bullet_coordinator'
  end

  after do
    restore_load_path
  end

  it "establishes objects that should, when summoned (even from objects in sub contexts), be constructed in the declarer's context" do
    subject.has?(:bullet_coordinator).should be_false
    subject.instance_variable_get(:@cache).keys.should_not include(:bullet_coordinator)
    
    subject[:game]

    subject.has?(:bullet_coordinator).should be_true
    subject.instance_variable_get(:@cache).keys.should_not include(:bullet_coordinator) # shouldn't actually be there

    sub1 = nil
    bullet1 = nil
    subject.in_subcontext do |sub|
      sub1 = sub
      bullet1 = sub[:bullet]
    end

    bullet1.should be

    sub2 = nil
    bullet2 = nil
    subject.in_subcontext do |sub|
      sub2 = sub
      bullet2 = sub[:bullet]
    end

    bullet2.should be

    bullet1.should_not == bullet2
    sub1.should_not == subject
    sub1.should_not == sub2

    subject.has?(:bullet_coordinator).should be_true
    subject.instance_variable_get(:@cache).keys.should include(:bullet_coordinator) 

    bullet1.bullet_coordinator.should be
    bullet1.bullet_coordinator.should == subject[:bullet_coordinator]

    bullet2.bullet_coordinator.should be
    bullet2.bullet_coordinator.should == subject[:bullet_coordinator]

    sub1[:bullet_coordinator].should == subject[:bullet_coordinator]
    sub2[:bullet_coordinator].should == subject[:bullet_coordinator]
  end

  it "allows subcontexts to shadow parent context objects" do
    # Instantiate objs in super context
    game = subject[:game]
    # See it working normally: bullets in subcontexts should cause the bc to be built in the super
    bullet1 = nil
    subject.in_subcontext do |sub|
      bullet1 = sub[:bullet]
    end
    bc1 = subject[:bullet_coordinator]
    bc1.should be
    bullet1.bullet_coordinator.should == bc1

    # Now try a shadow:
    game2 = nil
    bc2 = nil
    subject.in_subcontext do |sub|
      game2 = sub[:alt_game] # This class declares bullet_coordinator as an object peer, so we should be getting a newly built coord...
      bc2 = sub[:bullet_coordinator]
    end
    game2.should be
    bc2.should be

    bc2.should_not == bc1
  end
end

