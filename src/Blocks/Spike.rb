module Blocks
  class Spike < Block
    def setup
      super
      @safe = false
    end
  end
end
