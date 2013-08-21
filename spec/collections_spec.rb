require 'spec_helper'

describe "Hamsterdam's immutable persistent data structures" do

  describe "list" do
    describe "an empty list" do
      subject { Hamsterdam.list }

      it "is a conforming empty list" do
        subject.should == subject
        subject.inspect.should == "[]"
        subject.reverse.should == subject
        subject.cons(1).should == Hamsterdam.list(1)
        subject.reject { |i| i % 2 == 0 }.should == subject
        subject.reduce(0) { |total, i| total + i }.should == 0
        subject.map { |i| i+1 }.should == subject
        subject.compact.should == subject
        subject.flatten.should == subject
        subject.uniq.should == subject
        subject.last.should == nil
        subject.to_a.should == []
        subject.to_ary.should == []
        subject.to_set.should == Hamsterdam.set
      end
    end

    describe "a populated list" do
      subject { Hamsterdam.list("a", "b", "c") }

      it "is a conforming list" do
        subject.should == subject

        subject.to_ary.should == ["a", "b", "c"]
        subject.to_a.should == ["a", "b", "c"]
        subject.cons("d").should == Hamsterdam.list("d", "a", "b", "c")
        subject.inspect.should == ["a", "b", "c"].inspect
        subject.reverse.should == Hamsterdam.list("c", "b", "a")
        subject.reject { |char| char == "b" }.should == Hamsterdam.list("a", "c")
        subject.cons(Hamsterdam.list("d")).flatten.should == Hamsterdam.list("d", "a", "b", "c")
        subject.cons("a").uniq.should == subject
        subject.last.should == "c"
        subject.cons(nil).compact.should == subject
        subject.reduce("Word: ") { |str, char| "#{str}#{char}"}.should == "Word: abc"
        subject.inject("Word: ") { |str, char| "#{str}#{char}"}.should == "Word: abc"
        subject.map { |char| "#{char}!" }.should == Hamsterdam.list("a!", "b!", "c!")
        subject.to_set.should == Hamsterdam.set("a", "b", "c")
      end
    end
  end

  describe "set" do
    describe "an empty set" do
      subject { Hamsterdam.set }

      it "is a conforming empty set" do
        subject.should == subject
        subject.inspect.should == "{}"
        subject.reject { |i| i % 2 == 0 }.should == subject
        (subject - [1,2,3]).should == subject
        subject.add("a").should == Hamsterdam.set("a")
        subject.reduce(0) { |total, i| total + i }.should == 0
        subject.map { |i| i+1 }.should == subject
        subject.compact.should == subject
        subject.flatten.should == subject
        subject.delete("a").should == subject
        subject.to_a.should == []
        subject.to_ary.should == []
      end
    end

    describe "a populated set" do
      subject { Hamsterdam.set("a", "b", "c", "a") }

      it "is a conforming list" do
        subject.should == subject

        subject.add("d").should == Hamsterdam.set("d", "a", "b", "c")
        subject.inspect.should =~ /^\{"(a|b|c)", "(a|b|c)", "(a|b|c)"\}$/
        subject.reject { |char| char == "b" }.should == Hamsterdam.set("a", "c")
        (subject - ["c", "a"]).should == Hamsterdam.set("b")
        subject.add(Hamsterdam.set("d")).flatten.should == Hamsterdam.set("d", "a", "b", "c")
        subject.add(nil).compact.should == subject
        subject.reduce("Word: ") { |str, char| "#{str}#{char}"}.should =~ /^Word: (a|b|c)(a|b|c)(a|b|c)$/
        subject.inject("Word: ") { |str, char| "#{str}#{char}"}.should =~ /^Word: (a|b|c)(a|b|c)(a|b|c)$/
        subject.map { |char| "#{char}!" }.should == Hamsterdam.set("a!", "b!", "c!")
        subject.to_ary.sort.should == ["a", "b", "c"]
        subject.to_a.sort.should == ["a", "b", "c"]
      end
    end
  end

  describe "hash" do
    describe "an empty hash" do
      subject { Hamsterdam.hash}

      it "is a conforming empty hash" do
        subject.should == subject
        subject.put("hey", "now").should == Hamsterdam.hash("hey" => "now")
        subject.delete("hey").should == subject
      end
    end

    describe "a populated hash" do
      subject { Hamsterdam.hash(foo: "a", bar: "b", qux: "c") }

      it "is a confirming populated hash" do
        subject.should == subject
        subject.put(:foot, "bart").should == Hamsterdam.hash(foo: "a", bar: "b", qux: "c", foot: "bart")
        subject.delete(:bar).should == Hamsterdam.hash(foo: "a", qux: "c")
      end
    end
  end

  describe "queue" do
    describe "an empty queue" do
      subject { Hamsterdam.queue }

      it "is a conforming empty queue" do
        subject.should == subject
        subject.inspect.should == [].inspect
        subject.dequeue.should == subject
        subject.enqueue("a").should == Hamsterdam.queue("a")
      end
    end

    describe "a populated queue" do
      subject { Hamsterdam.queue("a", "b", "c") }

      it "is a conforming populated queue" do
        subject.should == subject
        subject.inspect.should == ["a", "b", "c"].inspect
        subject.dequeue.should == Hamsterdam.queue("b", "c")
        subject.enqueue("d").should == Hamsterdam.queue("a", "b", "c", "d")
      end
    end
  end
end
