class ClassThatUsesContextInInit
  attr_reader :init_time_object_context

  def initialize
    @init_time_object_context = object_context
  end
end
