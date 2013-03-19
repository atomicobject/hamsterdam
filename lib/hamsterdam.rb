require 'hamster'

module Hamsterdam

  module Hamster

    def self.hash(*hash)
      ::Hamster.hash(*hash)
    end

    def self.set(*values)
      ::Hamster.set(*values)
    end

    def self.list(*values)
      ::Hamster.list(*values)
    end

    def self.internal_hash_class
      ::Hamster::Hash
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
    @internal_representation_module
  end

  def self.hash(*hash)
    internals.hash(*hash)
  end

  def self.set(*values)
    internals.set(*values)
  end

  def self.list(*values)
    internals.list(*values)
  end

  def self.internal_hash_class
    internals.internal_hash_class
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

      struct_class.instance_variable_set(:@field_names, Hamsterdam.set(*field_names))
      struct_class.instance_variable_set(:@field_names_list, Hamsterdam.list(*field_names))
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

    def initialize(values=Hamsterdam.hash, validate=true)
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
      internal_hash == other.internal_hash
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
    alias_method :to_hamster_hash, :internal_hash

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
      bad_keys = data.keys - valid_keys.to_a
      if bad_keys.any?
        raise "#{self.class.name || "Anonymous Hamsterdam::Struct"} can't be constructed with #{bad_keys.inspect}. Valid keys: #{valid_keys.inspect}"
      end
    end

    def ensure_expected_hash(h)
      case h
      when Hash
        Hamsterdam.hash(h)
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
Hamsterdam.internals = Hamsterdam::Hamster
