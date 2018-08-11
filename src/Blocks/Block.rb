module Blocks
  class Block < AdventureRL::Image
    include AdventureRL::Modifiers::Solid

    def setup
      @precision_over_performance = false
      @safe = true
    end

    def is_safe?
      return !!@safe
    end
  end
end
