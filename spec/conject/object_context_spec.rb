require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Conject::ObjectContext do
  subject do
    Conject::ObjectContext.new(:parent_context => parent_context, :object_factory => object_factory)
  end

  let :parent_context do mock(:parent_context) end
  let :object_factory do mock(:object_factory) end

  describe "#get" do
    describe "when an object has been #put" do
      before { subject.put(:kraft, "verk") }

      it "returns the #put object" do
        subject.get(:kraft).should == "verk"
      end

      it "can use strings and symbols interchangebly" do
        subject.get('kraft').should == "verk"

        subject.put('happy', 'hat')
        subject.get('happy').should == 'hat'
        subject.get(:happy).should == 'hat'
      end

      it "support [] as shorthand for get and []= for put" do
        subject['kraft'].should == "verk"

        subject['happy'] = 'hat'
        subject['happy'].should == 'hat'
        subject[:happy].should == 'hat'
      end
    end

    describe "when the object is not in the cache" do
      describe "and the parent context has got the requested object" do
        before do
          parent_context.should_receive(:has?).with(:cheezburger).and_return(true)
          parent_context.should_receive(:get).with(:cheezburger).and_return("can haz")
        end

        it "returns the object from the parent context" do
          subject.get(:cheezburger).should == "can haz"
        end
      end

      describe "and the parent context does NOT have the requested object" do
        before do
          parent_context.should_receive(:has?).with(:cheezburger).and_return(false)
          parent_context.should_not_receive(:get)
          @but_i_ated_it = Object.new
          object_factory.should_receive(:construct_new).with(:cheezburger, subject).and_return(@but_i_ated_it)
        end

        # NOTE: these examples are identical to those in the spec for missing parent context (below)
        it "constructs the object anew using the object factory" do
          subject.get(:cheezburger).should == @but_i_ated_it
        end

        it "caches the results of using the object facatory" do
          subject.get(:cheezburger).should == @but_i_ated_it
          # mock object factory would explode if we asked it twice:
          subject.get(:cheezburger).should == @but_i_ated_it
        end

      end

      describe "but there is no parent context" do
        let :parent_context do nil end
        before do
          @but_i_ated_it = Object.new
          object_factory.should_receive(:construct_new).with(:cheezburger, subject).and_return(@but_i_ated_it)
        end

        # NOTE: these examples are identical to those in the spec for parent context not having the object (above)
        it "constructs the object anew using the object factory" do
          subject.get(:cheezburger).should == @but_i_ated_it
        end

        it "caches the results of using the object facatory" do
          subject.get(:cheezburger).should == @but_i_ated_it
          # mock object factory would explode if we asked it twice:
          subject.get(:cheezburger).should == @but_i_ated_it
        end
      end
    end
  end

  describe "#put?" do
    it "raises an error if the context already has an object with the given name" do
      subject[:jack] = :sparrow
      lambda do subject[:jack] = :and_jill end.should raise_error /jack/
    end

    it "raises an error if the context has a config for the given name, even if no object has been instantiated or registered yet" do
      subject.configure_objects davie: { cache: false }
      lambda do subject[:davie] = :jones end.should raise_error /davie/
    end
  end

  describe "#has?" do
    describe "when the object exists in the cache" do
      describe "due to #put" do
        it "returns true" do
          subject.put(:a_clue, "Wodsworth")
          subject.has?(:a_clue).should be_true
          subject.has?(:a_clue).should be_true # do it again for good measure
        end
      end
      describe "due to caching a previous #get" do
        before do
          parent_context.stub(:has?).and_return(false)
          object_factory.stub(:construct_new).and_return("Mr Green")
        end
        it "returns true" do
          subject.get(:a_clue).should == "Mr Green"
          subject.has?(:a_clue).should be_true
          subject.has?(:a_clue).should be_true # do it again for good measure
        end
      end
    end

    describe "when the object does NOT exist in the cache" do
      describe "when there is no parent context" do
        let :parent_context do nil end
        it "returns false" do
          subject.has?(:a_clue).should == false
        end
      end

      describe "when there is a parent context" do
        it "delegates the question to the parent context" do
          parent_context.should_receive(:walk_up_contexts).and_yield(parent_context)
          parent_context.should_receive(:directly_has?).with(:a_clue).and_return(true)
          subject.has?(:a_clue).should == true
        end
      end

    end
  end

  describe "#directly_has?" do
    describe "when the object exists in the cache" do
      describe "due to #put" do
        it "returns true" do
          subject.put(:a_clue, "Wodsworth")
          subject.directly_has?(:a_clue).should be_true
          subject.directly_has?(:a_clue).should be_true # twice for luck
          subject.directly_has?('a_clue').should be_true # twice for luck
        end
      end
      describe "due to caching a previous #get" do
        before do
          parent_context.stub(:has?).and_return(false)
          object_factory.stub(:construct_new).and_return("Mr Green")
        end
        it "returns true" do
          subject.get(:a_clue).should == "Mr Green"
          subject.directly_has?(:a_clue).should be_true
          subject.directly_has?('a_clue').should be_true
        end
      end
    end

    describe "when the object does NOT exist in the cache" do
      describe "and there's no config for the object" do
        it "returns false" do
          subject.directly_has?(:a_clue).should == false
        end
      end
      describe "and there IS a config for the object" do
        it "returns true" do
          subject.configure_objects :a_clue => { :cache => false }
          subject.directly_has?(:a_clue).should == true
        end
      end
    end
  end

  describe "#in_subcontext" do
    it "yields a new context with the given context as its parent" do
      subcontext_executed = false
      subsubcontext_executed = false
      ident = Object.new
      subject.put("identifier", ident)
      subject.in_subcontext do |subcontext|
        subcontext_executed = true
        subcontext.class.should == Conject::ObjectContext # See it's an ObjectContext
        subcontext.object_id.should_not == subject.object_id # See it's different
        subcontext.get("identifier").object_id.should == ident.object_id # See it has access to the parent

        ident2 = Object.new
        subcontext.put("sub_ident", ident2)
        subcontext.in_subcontext do |subsub|
          subsubcontext_executed = true
          subsub.class.should == Conject::ObjectContext # See it's an ObjectContext
          subsub.object_id.should_not == subject.object_id # See it's different
          subsub.object_id.should_not == subcontext.object_id # See it's different
          subsub.get("identifier").object_id.should == ident.object_id # See it has access to the parent
          subsub.get("sub_ident").object_id.should == ident2.object_id # See it has access to the parent's parent
        end
      end
      subcontext_executed.should be_true
      subsubcontext_executed.should be_true
    end
  end

  describe "#configure_objects" do
    describe ":cache => false" do
      before do
        parent_context.stub(:has?).and_return(false)
        parent_context.should_not_receive(:get)
        @first_burger = "first burger"
        @second_burger = "second burger"

        subject.configure_objects :cheezburger => { :cache => false }
      end

      it "causes the Context not to cache a constructed object, but to build new each time" do
        object_factory.should_receive(:construct_new).with(:cheezburger, subject).and_return(@first_burger)
        object_factory.should_receive(:construct_new).with(:cheezburger, subject).and_return(@second_burger)

        subject[:cheezburger].should == @first_burger
        subject[:cheezburger].should == @second_burger
      end
    end

    # describe "for already-cached objects" do
    #   it "raises an error"
    # end

  end

  describe "#inspect and #to_s" do
    it "shows a custom string based on object_id" do
      c = subject
      obj_id_hex = c.object_id.to_s(16)
      c.inspect.should == "<ObjectContext 0x#{obj_id_hex}>"
      c.to_s.should    == "<ObjectContext 0x#{obj_id_hex}>"
    end
  end
end
