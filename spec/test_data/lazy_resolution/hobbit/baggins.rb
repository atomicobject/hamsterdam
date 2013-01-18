module Hobbit
  class Baggins
    provide_with_objects "hobbit/shire", "hobbit/precious"

    def to_s
      "From the #{shire}, found the #{precious}"
    end

  end
end
