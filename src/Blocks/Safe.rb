module Blocks
  class Safe < Block
    def setup
      super
      @safe = true
    end
  end
end
