
module Hamsterdam
  module Clojure
    java_import 'clojure.lang.PersistentList$EmptyList'
    List = Java::ClojureLang::PersistentList
    Hash = Java::ClojureLang::PersistentHashMap
    Set = Java::ClojureLang::PersistentHashSet
    Queue = Java::ClojureLang::PersistentQueue

    def self.hash(h = nil)
      if h.nil?
        Hash::EMPTY
      else
        Hash.create(h)
      end
    end

    def self.internal_hash_class
      Hash
    end

    def self.set(*values)
      Set.create(values)
    end

    def self.list(*values)
      List.create(values).pop
    end

    def self.queue(*values)
      Queue.create(values)
    end

    def self.symbolize_keys(hash)
      hash.reduce(hash) do |memo,(k,v)|
        if Symbol === k
          memo
        else
          memo.delete(k).put(k.to_sym, v)
        end
      end
    end
  end
end

class Hamsterdam::Clojure::Hash
  alias_method :put, :assoc
  alias_method :delete, :without
  alias_method :==, :equals
end

class Hamsterdam::Clojure::Queue
  alias_method :dequeue, :pop
  alias_method :enqueue, :cons

  def inspect
    to_a.inspect
  end

  def self.create(values)
    values.inject(Hamsterdam::Clojure::Queue::EMPTY) do |queue, val|
      queue.cons(val)
    end
  end
end

class Hamsterdam::Clojure::EmptyList
  def inspect
    "[]"
  end

  alias_method :to_ary, :to_a

  def reverse
    self
  end

  def reject(&block)
    self
  end

  def reduce(initial)
    initial
  end

  def map
    self
  end

  def compact
    self
  end

  def to_set
    Java::ClojureLang::PersistentHashSet::EMPTY
  end

  def flatten
    self
  end

  def uniq
    self
  end

  def last
    nil
  end

  def delete(entry)
    self
  end
end

class Hamsterdam::Clojure::List

  def inspect
    to_a.inspect
  end

  alias_method :to_ary, :to_a

  def reverse
    make_list to_a.reverse
  end

  def reject(&block)
    make_list to_a.reject(&block)
  end

  def flatten
    make_list to_a.flatten
  end

  def uniq
    make_list to_a.uniq
  end

  def last
    to_a.reverse.first
  end

  def compact
    reject { |e| e.nil? }
  end

  def reduce(initial, &block)
    to_a.inject(initial, &block)
  end
  alias_method :inject, :reduce

  def map(&block)
    make_list to_a.map(&block)
  end

  def delete(entry)
    reject { |i| i == entry }
  end

  def to_set
    Hamsterdam::Clojure::Set.create(to_a)
  end

  private
  def make_list(array)
    Hamsterdam::Clojure::List.create(array).pop
  end
end

class Hamsterdam::Clojure::Set

  def inspect
    to_a.inspect.sub(/^\[/, "{").sub(/\]$/, "}")
  end

  def reject(&block)
    make_set to_a.reject(&block)
  end

  def subtract(enumerable)
    reject { |e| enumerable.include?(e) }
  end

  def reduce(initial, &block)
    to_a.inject(initial, &block)
  end

  def map(&block)
    make_set to_a.map(&block)
  end

  def flatten
    make_set to_a.flatten
  end

  def compact
    reject { |e| e.nil? }
  end

  alias_method :delete, :disjoin
  alias_method :to_ary, :to_a
  alias_method :add, :cons
  alias_method :-, :subtract
  alias_method :inject, :reduce

  private
  def make_set(array)
    Hamsterdam::Clojure::Set.create(array)
  end
end

Hamsterdam.internals = Hamsterdam::Clojure
