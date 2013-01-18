require 'hamster'

module Hamsterdam
  VERSION = "1.0.1"

  class Struct
    def self.define(*field_names)
      struct_class = Class.new(Hamsterdam::Struct) do
        field_names = field_names.map &:to_sym
        field_names.each do |fname|
          define_method fname do 
            return @data[fname]
          end

          define_method "set_#{fname}" do |value|
            self.class.new(@data.put(fname, value))
          end
        end

      end

      struct_class.instance_variable_set(:@field_names, Hamster.set(*field_names))
      struct_class.instance_variable_set(:@field_names_list, Hamster.list(*field_names))
      class << struct_class 
        def field_names
          @field_names
        end
        def field_names_list
          @field_names_list
        end
      end
      struct_class
    end

    def initialize(values=Hamster.hash)
      @data = flesh_out(ensure_hamster_hash(values))
      validate_keys(@data)
    end

    def merge(values)
      self.class.new(@data.merge(ensure_hamster_hash(values)))
    end

    def ==(other)
      @data == other.to_hamster_hash
    end

    def eql?(other)
      self.class == other.class && self == other
    end

    def hash
      @data.hash
    end

    def to_hamster_hash
      @data
    end

    def inspect
      to_s
    end

    def to_s
      name = self.class.name.split(/::/).last
      data = to_hamster_hash
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

    def ensure_hamster_hash(h)
      case h
      when Hash
        Hamster.hash(h)
      when Hamster::Hash
        h
      else
        raise "Expected Hash or Hamster::Hash. Do not want: #{h.inspect}"
      end
    end

    def flesh_out(data)
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
      data.reduce(data) do |memo,k,v|
        if Symbol === k
          memo
        else
          memo.delete(k).put(k.to_sym, v)
        end
      end
    end
  end
end
