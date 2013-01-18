
require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "nested contexts" do
  subject { new_object_context }

  let(:root_context) { subject }

  before do
    append_test_load_path "basic_composition"
    require 'lobby'
    require 'front_desk'
    require 'guest'
    require 'tv'
    require 'grass'
  end

  after do
    restore_load_path
  end

  it "can create an object within a subcontext" do
    root_context.in_subcontext do |hotel|
      front_desk = hotel[:front_desk]
      front_desk.should be
      front_desk.class.should == FrontDesk
    end
  end

  it "reuse objects within themselves, but do not share with peer contexts" do
    front_desk = nil
    another_front_desk = nil

    root_context.in_subcontext do |hotel|
      front_desk = hotel[:front_desk]
      hotel[:front_desk].object_id.should == front_desk.object_id
      hotel.directly_has?(:front_desk).should be_true
    end

    root_context.in_subcontext do |hotel|
      another_front_desk = hotel[:front_desk]
      hotel[:front_desk].object_id.should == another_front_desk.object_id
    end

    another_front_desk.object_id.should_not == front_desk.object_id
  end

  it "provide dependencies by generating objects within itself" do
    root_context.in_subcontext do |hotel|
      lobby = hotel[:lobby]
      lobby.front_desk.should be
      lobby.front_desk.should == hotel[:front_desk]

      hotel.directly_has?(:front_desk).should be_true
      hotel.directly_has?(:lobby).should be_true

      root_context.has?(:front_desk).should_not be_true
      root_context.has?(:lobby).should_not be_true
    end
  end

  it "provide dependencies via its parent context, THEN generating objects within itself" do
    root_context.in_subcontext do |hotel|
      lobby = hotel[:lobby] # this establishes the lobby and front desk in the hotel context

      hotel.in_subcontext do |room|
        guest = room[:guest]
        # Guest should have reference to TV from the room context, and front desk from the hotel context
        guest.tv.should be
        guest.front_desk.should be

        # Double check which contexts own which objects
        room.directly_has?(:guest).should be_true
        room.directly_has?(:tv).should be_true

        hotel.directly_has?(:guest).should_not be_true
        hotel.directly_has?(:tv).should_not be_true

        guest.front_desk.should == hotel[:front_desk]
        room.directly_has?(:front_desk).should_not be_true
        hotel.directly_has?(:front_desk).should be_true
      end
    end
  end

  it "assigns the correct object context to objects at each level" do
    grass = root_context[:grass]
    grass.should be
    grass.send(:object_context).should == root_context
    
    root_context.in_subcontext do |hotel|
      hotel.should_not == root_context
      front_desk = hotel[:front_desk]
      front_desk.send(:object_context).should == hotel
    end
  end

end

