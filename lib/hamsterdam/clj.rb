
class Java::ClojureLang::PersistentHashMap
  alias_method :put, :assoc
  alias_method :delete, :without
  alias_method :==, :equals
end

# java_import 'clojure.lang.PersistentList$EmptyList'
# class EmptyList
#   def inspect
#     to_a.inspect
#   end
# end
#
# class Java::ClojureLang::PersistentList
#   def inspect
#     to_a.inspect
#   end
# end
#
# class Java::ClojureLang::PersistentHashSet
#   def inspect
#     to_set.inspect
#   end
#
#   def -(other)
#     reject { |e| other.include?(e) }
#   end
#
#   alias_method :add, :cons
# end

module Hamsterdam
  module Clojure
    def self.hash(h = nil)
      if h.nil?
        Java::ClojureLang::PersistentHashMap::EMPTY
      else
        Java::ClojureLang::PersistentHashMap.create(h)
      end
    end

    def self.internal_hash_class
      Java::ClojureLang::PersistentHashMap
    end

    # def self.set(*values)
    #   Java::ClojureLang::PersistentHashSet.create(values)
    # end

    # def self.list(*values)
    #   values.reverse.inject(Java::ClojureLang::PersistentList::EMPTY) do |list, value|
    #     list.cons(value)
    #   end
    # end

    def self.set(*values)
      ::Hamster.set(*values)
    end

    def self.list(*values)
      ::Hamster.list(*values)
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

Hamsterdam.internals = Hamsterdam::Clojure
