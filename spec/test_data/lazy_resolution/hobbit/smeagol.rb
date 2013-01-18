module Hobbit
  class Smeagol
    provide_with_objects "hobbit/precious"

    attr_reader :saying

    def initialize
      @saying = "They stole it from us, precious #{precious}"
    end
  end
end
