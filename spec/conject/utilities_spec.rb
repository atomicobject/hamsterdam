require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Conject::Utilities do
  subject do described_class end

  before do
    @class_a = Class.new do end
    @class_b = Class.new do 
      def initialize
      end
    end
    @class_c = Class.new do 
      def initialize(x)
      end
    end
  end

  describe ".has_zero_arg_constructor?" do
    it "returns true when a class defines no initialize method" do
      subject.has_zero_arg_constructor?(@class_a).should be_true
    end
    it "returns true when a class defines initialize method without args" do
      subject.has_zero_arg_constructor?(@class_b).should be_true
    end
    it "returns false when a class defines initialize method WITH args" do
      subject.has_zero_arg_constructor?(@class_c).should be_false
    end
  end

  describe ".generate_accessor_method_names" do
    context "simple object names" do
      it "returns symbol names straight up" do
        subject.generate_accessor_method_names(:another_item).should == [:another_item]
      end
      it "converts strings to symbols" do
        subject.generate_accessor_method_names("the_object").should == [:the_object]
      end
    end

    context "namespaced object names" do
      it "returns only the last step in the name" do
        subject.generate_accessor_method_names(:'one/two/three').should == [:one_two_three, :three]
      end
      it "converts strings to symbols" do
        subject.generate_accessor_method_names("/aye/bee/cee").should == [:aye_bee_cee, :cee]
      end
    end
  end

end
