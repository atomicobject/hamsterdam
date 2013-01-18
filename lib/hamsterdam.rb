module Hamsterdam
  VERSION = "1.0.0"

  class Struct
    def self.define(*field_names)
      struct_class = Class.new(Hamsterdam::Struct) do
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
      class << struct_class 
        def field_names
          @field_names
        end
      end
      struct_class
    end

    def initialize(values=Hamster.hash)
      @data = ensure_hamster_hash(values)
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

  end
end
