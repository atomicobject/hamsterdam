require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "basic inheritance" do
  subject { new_object_context }

  before do
    append_test_load_path "inheritance"
    require 'vehicle'
    require 'wheel'
    require 'body'
    require 'car'
    require 'malibu'
    require 'emblem'
  end

  context "simple subclasses of a class that uses construct_with" do
    it "gets built with its superclass's dependencies" do
      # Check the base type object:
      vehicle = subject[:vehicle]
      vehicle.should be
      vehicle.hit_body.should == "body!"
      vehicle.hit_wheel.should == "wheel!"
      
      # grab the subtype object:
      car = subject[:car]
      car.should be
      car.hit_body.should == "body!"
      car.hit_wheel.should == "wheel!"
    end
  end

  context "class three levels deep in inheritance, adding a dep" do
    it "works" do
      malibu = subject[:malibu]
      malibu.hit_body.should == "body!"
      malibu.hit_wheel.should == "wheel!"
      malibu.hit_emblem.should == "chevy!"
    end
  end

  context "[initializers]" do
    context "superclass has 0-arg #initialize" do
      class Mammal
        construct_with :fur
        attr_reader :temp
        def initialize
          @temp = 98.6
        end
      end

      class Fur; end
      class Tree; end

      it "invokes super #initialize" do
        m = subject[:mammal]
        m.temp.should == 98.6
      end

      context "subclass has default #initialize" do
        class Cat < Mammal
          construct_with :fur
        end

        it "invokes superclass #initialize" do
          subject[:cat].temp.should == 98.6
        end
      end

      context "subclass has 1-arg #initialize that invokes #super" do
        class Ape < Mammal
          construct_with :fur,:tree
          attr_accessor :got_map
          def initialize(map)
            @got_map = map
            super
          end
        end

        let(:chauncy) { subject[:ape] }

        it "invokes subclass custom #initialize with component map" do
          fur = subject[:fur]
          tree = subject[:tree]
          chauncy.got_map.should == { :fur => fur, :tree => tree }
        end

        it "invokes superclass #initialize" do
          chauncy.temp.should == 98.6
        end
      end

      context "subclass has 0-arg #initialize that invokes #super" do
        class Dog < Mammal
          construct_with :fur
          attr_accessor :legs
          def initialize
            @legs = 4
            super :whoa_there # superclass has a Conjected #initialize which requires the component map arg, though it's not used.  Ugh.
          end
        end
        
        let(:indy) { subject[:dog] }

        it "invokes subclass #initialize" do
          indy.legs.should == 4
        end

        it "invokes superclass #initialize" do
          indy.temp.should == 98.6
        end
      end

      context "subclass has a no-arg #initialize that does NOT invoke #super" do
        class Shrew < Mammal
          construct_with :fur
          def initialize
          end
        end

        it "does not invoke superclass #initiailize" do
          subject[:shrew].temp.should be_nil
        end
      end

      context "subclass has a 1-arg #initialize that does NOT invoke #super" do
        class Shrew < Mammal
          construct_with :fur
          def initialize(map)
          end
        end

        it "does not invoke superclass #initiailize" do
          subject[:shrew].temp.should be_nil
        end
      end
    end


    context "superclass has 1-arg #initialize" do
      class Reptile
        construct_with :scales
        attr_reader :super_map
        def initialize(map)
          @super_map = map
        end
      end

      class Scales; end
      class Rock; end
      class Shell; end

      it "invokes super #initialize with component map" do
        subject[:reptile].super_map.should == { :scales => subject[:scales] }
      end

      context "subclass has default #initialize" do
        class Snake < Reptile
          construct_with :scales
        end

        it "invokes superclass #initialize" do
          subject[:reptile].super_map.should == { :scales => subject[:scales] }
        end
      end

      context "subclass has 1-arg #initialize that invokes #super" do
        class Lizard < Reptile
          construct_with :scales,:rock
          attr_accessor :got_map
          def initialize(map)
            @got_map = map
            super
          end
        end

        let(:harry) { subject[:lizard] }

        it "invokes subclass custom #initialize with component map" do
          scales = subject[:scales]
          rock = subject[:rock]
          harry.got_map.should == { :scales => scales, :rock => rock }
        end

        it "invokes superclass #initialize with component_map" do
          scales = subject[:scales]
          rock = subject[:rock]
          harry.super_map.should == { :scales => scales, :rock => rock }
        end
      end

      #
      # This case--where a subclass has a user-defined #initialize, which does
      # not accept an argument (will not be passed the component map at construct time)
      # invokes super with some bs argument because we CANNOT SUPPLY super with its
      # needs.  User SHOULD accept the component_map as an argument to #initialize
      # and let the map float to super class.
      # 
      context "subclass has 0-arg #initialize that invokes #super" do
        class Turtle < Reptile
          construct_with :scales, :shell
          attr_accessor :tail
          def initialize
            @tail = true
            super :theres_ur_problem # stoopid
          end
        end
        
        let(:franklin) { subject[:turtle] }

        it "invokes subclass #initialize" do
          franklin.tail.should == true
        end

        it "invokes superclass #initialize with... fuh..." do
          franklin.super_map.should == :theres_ur_problem
        end
      end

      context "subclass has a no-arg #initialize that does NOT invoke #super" do
        class Aligator < Reptile
          construct_with :scales
          def initialize
          end
        end

        it "does not invoke superclass #initiailize" do
          subject[:aligator].super_map.should be_nil
        end
      end

      context "subclass has a 1-arg #initialize that does NOT invoke #super" do
        class Croc < Reptile
          construct_with :scales
          attr_reader :my_map
          def initialize(map)
            @my_map = map
          end
        end

        it "does not invoke superclass #initiailize" do
          subject[:croc].super_map.should be_nil
          subject[:croc].my_map.should == { :scales => subject[:scales] }
        end

      end
    end

  end

  context "subclass not declaring deps, though its superclass DOES have deps" do
    let(:parent) do
      Class.new do 
        construct_with :home, :money
      end
    end

    let(:child) do
      Class.new(parent) do
      end
    end

    it "raises an error at init time" do
      lambda do
        child.new nil
      end.should raise_error(/ancestor.*construct_with.*dependencies.*instantiate/)
    end
  end
end
