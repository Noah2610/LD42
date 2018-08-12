module Blocks
  class Block < AdventureRL::Animation
    include AdventureRL::Modifiers::Solid
    include AdventureRL::Modifiers::Pusher

    BLOCKS_STUCK_SOLID_TAG = :block_stuck

    DEFAULT_SETTINGS = AdventureRL::Settings.new(SETTINGS.get(:block))

    def self.parse_settings settings
      return DEFAULT_SETTINGS.merge(settings).merge(
        files: [DEFAULT_SETTINGS.merge(settings).get(:files)].flatten.map do |file|
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

    def is_stuck?
      return is_static?
    end

    def make_stuck
      make_static
      set_solid_tags BLOCKS_STUCK_SOLID_TAG
      set_solid_tags_collides_with nil
    end

    def is_colliding_with_objects objects
      #puts 'CHECK'  # TODO
      return      if (is_stuck?)
      make_stuck  if (objects.any? { |o| next (o.is_stuck?  rescue false) })
    end

    private

      def move_by_handle_collision_with_previous_position previous_position
        prev_pos = get_position.dup
        set_position y: (y - 1)
        colliding_objects = get_colliding_objects
        set_position prev_pos

        if (colliding_objects.any?)
          if (colliding_objects.any? &:is_static?)
            @position = previous_position
            return false
          end
          direction = get_position_difference_from previous_position
          # NOTE:
          # _Try_ to push objects, but _ALWAYS_ move itself.
          # Might cause Player to glitch into Blocks, be on the look-out.
          push_objects(colliding_objects, direction)
          return true
        end
        return true
      end

      def push_objects objects, direction
        direction[:precision_over_performance] = @precision_over_performance
        return objects.all? do |object|
          next true  if (@pushed_by_pusher && @pushed_by_pusher.include?(object))
          next object.move_by(direction.merge(pushed_by_pusher: @pushed_by_pusher))
        end
      end
  end
end
