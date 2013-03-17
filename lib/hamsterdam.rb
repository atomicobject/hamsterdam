require 'hamster'

module Hamsterdam

  module Hamster
    def self.from_ruby_hash(h)
      ::Hamster.hash(h)
    end

    def self.internal_hash_class
      ::Hamster::Hash
    end

    def self.empty_hash
      ::Hamster.hash
    end

    def self.empty_set
      ::Hamster.set
    end

    def self.empty_list
      ::Hamster.list
    end

    def self.equal_hashes?(hash1, hash2)
      hash1 == hash2
    end

    def self.symbolize_keys(hash)
      hash.reduce(hash) do |memo,k,v|
        if Symbol === k
          memo
        else
          memo.delete(k).put(k.to_sym, v)
        end
      end
    end
  end

  def self.Struct(*field_names)
    Hamsterdam::Struct.define(*field_names)
  end

  def self.internals=(mod)
    @internal_representation_module = mod
  end

  def self.internals
    @internal_representation_module || Hamsterdam::Hamster
  end

  def self.from_ruby_hash(h)
    internals.from_ruby_hash(h)
  end

  def self.internal_hash_class
    internals.internal_hash_class
  end

  def self.empty_hash
    internals.empty_hash
  end

  def self.empty_set
    internals.empty_set
  end

  def self.empty_list
    internals.empty_list
  end

  def self.equal_hashes?(hash1, hash2)
    internals.equal_hashes?(hash1, hash2)
  end

  def self.symbolize_keys(hash)
    internals.symbolize_keys(hash)
  end

  class Struct
    def self.define(*field_names)
      struct_class = Class.new(Hamsterdam::Struct) do
        field_names = field_names.map &:to_sym
        field_names.each do |fname|
          define_method fname do 
            @data[fname]
          end

          define_method "set_#{fname}" do |value|
            if @data[fname] == value
              self
            else
              self.class.new(@data.put(fname, value), false)
            end
          end
        end

      end

      struct_class.instance_variable_set(:@field_names, ::Hamster.set(*field_names))
      struct_class.instance_variable_set(:@field_names_list, ::Hamster.list(*field_names))
      class << struct_class 
        def field_names
          if !@field_names.nil?
            @field_names
          else
            superclass.field_names
          end
        end
        def field_names_list
          if !@field_names_list.nil?
            @field_names_list
          else
            superclass.field_names_list
          end
        end
      end
      struct_class
    end

    def initialize(values=Hamsterdam.empty_hash, validate=true)
      if validate
        @data = flesh_out(ensure_expected_hash(values))
        validate_keys(@data)
      else
        @data = values
      end
    end

    def merge(values)
      self.class.new(@data.merge(ensure_expected_hash(values)))
    end

    def ==(other)
      Hamsterdam.equal_hashes?(@data, other.internal_hash)
    end

    def eql?(other)
      self.class == other.class && self == other
    end

    def hash
      @data.hash
    end

    def internal_hash
      @data
    end

    def inspect
      to_s
    end

    def to_s
      name = self.class.name ? self.class.name.split(/::/).last : self.class.to_s
      data = internal_hash
      fields = self.class.field_names_list.map { |fname| "#{fname}: #{data[fname].inspect}" }
      "<#{([name]+fields).join(" ")}>"
    end

    private
    def validate_keys(data)
      valid_keys = self.class.field_names
      bad_keys = data.keys - valid_keys
      if bad_keys.any?
        raise "#{self.class.name || "Anonymous Hamsterdam::Struct"} can't be constructed with #{bad_keys.inspect}. Valid keys: #{valid_keys.inspect}"
      end
    end

    def ensure_expected_hash(h)
      case h
      when Hash
        Hamsterdam.from_ruby_hash(h)
      when Hamsterdam.internal_hash_class
        h
      else
        raise "Expected Hash or #{Hamsterdam.internal_hash_class}. Do not want: #{h.inspect}"
      end
    end

    def flesh_out(data)
      # binding.pry
      fnames = self.class.field_names
      data = symbolize_keys(data)
      miss = fnames - data.keys
      if miss.any?
        return miss.inject(data) { |h,name| h.put(name,nil) }
      else
        return data
      end
    end

    def symbolize_keys(data)
      Hamsterdam.symbolize_keys(data)
    end
  end
end
