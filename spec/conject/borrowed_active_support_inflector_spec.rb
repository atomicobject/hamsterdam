require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

#
# Some super-basic specs that don't really exercise Inflector,
# but demonstrate that we have this capability built-in 
# when using ObjectContext.
#
describe "Borrowed ActiveSupport Inflector" do
  describe "#camelize" do
    it "converts underscored strings to camel case" do
      "four_five_six".camelize.should == "FourFiveSix"
    end

    it "leaves camel case words along" do
      "HoppingSizzler".camelize.should == "HoppingSizzler"
    end
  end

  describe "#underscore" do
    it "converts camel-case words to underscored" do
      "HoppingSizzler".underscore.should == "hopping_sizzler"
    end

    it "leaves underscored strings alone" do
      "four_five_six".underscore.should == "four_five_six"
    end
  end
end
