require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "object_context:" do
  subject { new_object_context }

  before do
    append_test_load_path "basic_composition"
    require 'kill_em_all'
    require 'ride_the_lightning'
    require 'master_of_puppets'
    require 'and_justice_for_all'
  end

  after do
    restore_load_path
  end

  describe "NEW AND IMPROVED" do

    describe "Class" do
      it "has the default object context" do
        Class.object_context.should == Conject.default_object_context
      end
    end

    describe "Object" do
      it "has the default object context at the class level" do
        Object.object_context.should == Conject.default_object_context
      end
      it "has the default object context at the instance level" do
        Object.new.object_context.should == Conject.default_object_context
        "whatever".object_context.should == Conject.default_object_context
        42.object_context.should == Conject.default_object_context
      end
    end

    describe "any ol' instance" do
      class FadeToBlack
      end

      let(:context1) { new_object_context }
      let(:context2) { new_object_context }
      let(:fade1) { FadeToBlack.new }
      let(:fade2) { FadeToBlack.new }

      it "can have object_context specified" do
        Conject.install_object_context fade1, context1
        fade1.object_context.should == context1
        fade2.object_context.should == Conject.default_object_context
      end

      it "can have the default object context overridden by Thread-local settings" do
        fade1.object_context.should == Conject.default_object_context

        Conject.override_object_context_with(context2) do
          fade1.object_context.should == context2
        end

        fade1.object_context.should == Conject.default_object_context
      end

      it "will prefer its installed object context to the magic override" do
        Conject.install_object_context fade1, context1
        fade1.object_context.should == context1

        Conject.override_object_context_with(context2) do
          fade1.object_context.should == context1 # shouldn't change
        end

        fade1.object_context.should == context1
      end
    end

    describe "classes using construct_with" do
      let(:justice) { subject.get('and_justice_for_all') }
      let(:ride) { subject.get('ride_the_lightning') }

      it "automatically get a private accessor for object_context, even if not requested" do
        justice.object_context.should == subject
        ride.object_context.should == subject # watching out for interaction bugs wrt dependency construction
      end

      it "can use object_context in initialize" do
        justice.init_time_object_context.should == subject
        ride.init_time_object_context.should == subject # watching out for interaction bugs wrt dependency construction
      end

      it "will get object_context assigned as a result of being set into a context" do
        obj = AndJusticeForAll.new(ride_the_lightning: 'doesnt matter')
        obj.object_context.should == Conject.default_object_context

        c2 = new_object_context
        c2[:my_obj] = obj
        obj.object_context.should == c2
      end
    end

    describe "classes NOT using construct_with" do
      let(:ride) { subject.get('ride_the_lightning') }

      it "automatically get a private accessor for object_context, even if not requested" do
        ride.object_context.should == subject
      end

      it "can use object_context in initialize" do
        ride.init_time_object_context.should == subject
      end

      it "will get object_context assigned as a result of being set into a context" do
        obj = KillEmAll.new
        obj.object_context.should == Conject.default_object_context

        c2 = new_object_context
        c2[:my_obj] = obj
        obj.object_context.should == c2
      end
    end

  end

  describe "OLD SCHOOL :this_object_context" do
    it "ObjectContext caches a reference to itself using the name :this_object_context" do
      subject[:this_object_context].should == subject
    end

    it "an object can inject :this_object_context as a reference to its constructing ObjectContext" do
      master = subject.get('master_of_puppets')
      master.this_object_context.should == subject

      master.this_object_context.get('master_of_puppets').should == master
    end
  end
end

