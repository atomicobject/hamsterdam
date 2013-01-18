require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")


describe "module scoping" do
  subject { new_object_context }

  describe "using fully qualified object name" do
    before do
      append_test_load_path "namespace"
      require 'chart/model'
      require 'chart/presenter'
      require 'chart/view'
    end

    after do
      restore_load_path
    end

    it "constructs objects with module-scoped classes" do
      obj = subject.get('chart/model')
      obj.should_not be_nil
      obj.class.should == Chart::Model
    end

    it "supports symbols as keys" do
      obj = subject.get(:'chart/model')
      obj.should_not be_nil
      obj.class.should == Chart::Model
    end

    it "lets objects depend on module-namespaced components" do
      obj = subject.get('chart/presenter')
      obj.should_not be_nil
      obj.class.should == Chart::Presenter

      model = obj.send(:chart_model)
      model.should be
      model.class.should == Chart::Model

      view = obj.send(:chart_view)
      view.should be
      view.class.should == Chart::View
    end

    it "provides short (relative) object name accessors in addition to canonical accessors" do
      obj = subject.get('chart/presenter')
      obj.should_not be_nil
      obj.class.should == Chart::Presenter

      model = obj.send(:model)
      model.should be
      model.class.should == Chart::Model

      view = obj.send(:view)
      view.should be
      view.class.should == Chart::View
    end
  end

  describe "using module-relative object names" do
    before do
      append_test_load_path "namespace"
      require 'deeply_nested/ez_chart/model'
      require 'deeply_nested/ez_chart/presenter'
      require 'deeply_nested/ez_chart/view'
    end

    after do
      restore_load_path
    end

    it "lets objects depend on module-namespaced components" do
      obj = subject.get('deeply_nested/ez_chart/presenter')
      obj.should_not be_nil
      obj.class.should == DeeplyNested::EzChart::Presenter

      model = obj.send(:model)
      model.should be
      model.class.should == DeeplyNested::EzChart::Model

      view = obj.send(:view)
      view.should be
      view.class.should == DeeplyNested::EzChart::View

      subject.directly_has?("deeply_nested/ez_chart/model").should be_true
      subject.directly_has?("deeply_nested/ez_chart/view").should be_true
    end
  end


end

