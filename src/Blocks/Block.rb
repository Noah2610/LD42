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
      @safe = true
    end

    def is_safe?
      return !!@safe
    end

    def is_unsafe?
      return !is_safe?
    end

    private

      # NOTE:
      # This is an _EXTREMELY_ hacky workaround for pushing the Player,
      # when they are standing on top of this Block.
      # Basically what we're doing is temporarily moving this Block upwards
      # so the collision checking that happens in `super` returns the Player,
      # if they are standing on top of this Block. Then we reset the position
      # to the previous state to avoid any further breakage.
      # BUT we only do this, if the method that is calling this method
      # is the one specified below (method from my framework), to also avoid further breakage.
      # Don't do this (except when you're in a jam, I guess that's understandable).
      # Thank you for reading, have a nice day :)
      def get_colliding_objects
        return super  unless (
          (caller.first.match(/`(\w+?)'\z/) || [])[1] == 'move_by_handle_collision_with_previous_position'
        )
        previous_position = get_position.dup
        set_position y: (y - 1)
        colliding_objects = super
        set_position previous_position
        return colliding_objects
      end
  end
end
