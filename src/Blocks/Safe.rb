module Blocks
  class Safe < Block
    DEFAULT_SETTINGS = AdventureRL::Settings.new(SETTINGS.get(:block).merge(SETTINGS.get(:safe_block)))

    def self.parse_settings settings
      return DEFAULT_SETTINGS.merge(settings).merge(
        files: [DEFAULT_SETTINGS.merge(settings).get(:files)].flatten.map do |file|
          next DIR[:images].join(file)
        end
      )
    end

    def setup
      super
      @safe = true
    end
  end
end
