module Blocks
  class Unsafe < Block
    DEFAULT_SETTINGS = AdventureRL::Settings.new(SETTINGS.get(:block).merge(SETTINGS.get(:unsafe_block)))

    def self.parse_settings settings
      return DEFAULT_SETTINGS.merge(settings).merge(
        files: [DEFAULT_SETTINGS.merge(settings).get(:files)].flatten.map do |file|
          next DIR[:images].join(file)
        end
      )
    end

    def setup
      super
      @safe = false
    end

    def make_stuck
      layer = get_layer
      layer.remove_object self  unless (layer.collides_with? self)
      make_static
      set_solid_tags BLOCKS_STUCK_SOLID_TAG
      set_solid_tags_collides_with nil
    end

    def is_colliding_with_objects objects
      return      if (is_stuck?)
      make_stuck  if (objects.any? { |o| next (o.is_stuck?  rescue false) })
    end
  end
end
