module Blocks
  class Unsafe < Block
    def setup
      super
      @safe = false
    end
  end
end
