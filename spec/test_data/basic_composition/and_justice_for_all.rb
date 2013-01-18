class AndJusticeForAll
  construct_with :ride_the_lightning

  attr_reader :init_time_object_context

  def initialize
    @init_time_object_context = begin 
                                  object_context
                                rescue
                                  nil
                                end
  end
end
