require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

#
# This set of specs isn't intended to exhaust metaid's functionality.
# Just to frame up something as a basis for test driving further mods.
#
describe "Extended metaid" do

  # Not testing:
  #   Object#metaclass
  #   Object#meta_eval
  # because we're not using them directly, don't plan to
  # change them, they're long-standing, widely-used Ruby 
  # metaprogramming methods, and we're using and testing
  # them indirectly through #metadef

  describe "Object#meta_def" do
    it "adds a method to an instance" do
      obj = Object.new
      obj2 = Object.new
      obj.meta_def :berzerker do
        37
      end

      obj.berzerker.should == 37
      lambda do obj2.berzerker.should == 37 end.should raise_error
    end
  end

  describe "Class#meta_def" do
    subject do 
      Class.new do
        def self.use_metaclass_method
          try_me
        end
      end
    end

    it "adds a method to the metaclass of a class" do
      subject.meta_def :try_me do "is nice" end
      subject.try_me.should == "is nice"
      subject.use_metaclass_method.should == "is nice"
    end
  end

  # Not testing
  #   Module#module_def
  #   Module#module_def_private
  # because we're not using them directly,
  # so let's move onto the class stuff
   
  describe "Class#class_def" do
    subject do
      Class.new
    end

    it "enables dynamic generation of new instance methods" do
      obj = subject.new

      subject.class_def :sgt do
        "highway"
      end

      obj.sgt.should == "highway"
      subject.new.sgt.should == "highway"
    end
  end

  describe "Class#class_def_private" do
    subject do
      Class.new
    end

    it "enables dynamic generation of new PRIVATE instance methods" do
      obj = subject.new

      subject.class_def_private :sgt do "highway" end


      # sgt is private so we shouldn't be able to call it outright
      lambda do obj.sgt end.should raise_error(NoMethodError)

      # Make a public method that can access it
      subject.class_def :gunnery do sgt end

      obj.gunnery.should == "highway"
    end
  end

end
