# Monkey patch clojure maps to have some of the same interface as Hamster hashes
class Java::ClojureLang::PersistentHashMap
  def put(key, val)
    assoc(key, val)
  end

  def delete(key)
    without(key)
  end
end

module Hamsterdam
  module Clojure
    def self.from_ruby_hash(h)
      Java::ClojureLang::PersistentHashMap.create(h)
    end

    def self.internal_hash_class
      Java::ClojureLang::PersistentHashMap
    end

    def self.empty_hash
      Java::ClojureLang::PersistentHashMap::EMPTY
    end

    def self.empty_set
      Java::ClojureLang::PersistentHashSet::EMPTY
    end

    def self.empty_list
      Java::ClojureLang::PersistentList::EMPTY
    end

    def self.equal_hashes?(hash1, hash2)
      hash1.equals(hash2)
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
