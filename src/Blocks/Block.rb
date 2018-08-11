module Blocks
  class Block < AdventureRL::Animation
    include AdventureRL::Modifiers::Solid
    include AdventureRL::Modifiers::Pusher

    DEFAULT_SETTINGS = SETTINGS.get(:block)

    def self.parse_settings settings
      return DEFAULT_SETTINGS.merge(settings).merge(
        files: [settings[:files]].flatten.map do |file|
          next DIR[:images].join(file)
        end
      )
    end

    def setup
      @precision_over_performance = false
      @safe = true
    end

    def is_safe?
      return !!@safe
    end

    def is_unsafe?
      return !is_safe?
    end
  end
end
