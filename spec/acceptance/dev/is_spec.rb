require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "':is'" do
  subject { new_object_context }

  before do
    append_test_load_path "basic_composition"
    require 'ride_the_lightning'
    require 'and_justice_for_all'
  end

  after do
    restore_load_path
  end

  it "lets you alias one object for another" do
    subject.configure_objects :album => { :is => :and_justice_for_all }
    album = subject[:album]

    album.should be
    album.class.should == AndJusticeForAll
    album.object_id.should == subject[:and_justice_for_all].object_id
  end

  it "provides good error message for missing target" do
    subject.configure_objects :album => { :is => :mule_variations }

    lambda do subject[:album] end.should raise_error(/when attempting to fill alias 'album'.*could not find.*MuleVariations/i)
  end


end

