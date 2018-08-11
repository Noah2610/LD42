class Player < AdventureRL::Animation
  include AdventureRL::Modifiers::Solid
  include AdventureRL::Modifiers::Velocity
  include AdventureRL::Modifiers::Gravity

  def setup settings
    setup_buttons_event_handler settings.get(:buttons)

    @speed = settings.get(:speed)
    @jump_standing_on_block_padding = settings.get(:jump_standing_on_block_padding)

    @is_jumping = false
    @has_jumped = false
  end

  def on_button_down btn
    #jump  if (btn == :jump)
  end

  def on_button_up btn
    @has_jumped = false  if (btn == :jump && @has_jumped)
  end

  def on_button_press btn, mod
    # TODO
    if (btn == :test)
      set_velocity y: 0
      return
    end

    if (has_method? btn)
      meth = method(btn)
      if (meth.arity == 1)
        meth.call mod
      else
        meth.call
      end
    end
  end

  def update
    super
    move
    if (@is_jumping)
      @is_jumping = false    if (bottom_is_touching_block?)
      hit_ceiling            if (get_velocity(:y) < 0 && top_is_touching_block?)
    end
    touching_unsafe_block    if (is_touching_unsafe_block?)
  end

  private

    def setup_buttons_event_handler settings
      @buttons_event_handler = AdventureRL::EventHandlers::Buttons.new settings
      @buttons_event_handler.subscribe self
    end

    def has_method? method_name
      return (methods.include?(method_name) || private_methods.include?(method_name))
    end

    def jump
      if (@is_jumping)
        return  unless (@has_jumped)  # return unless button is STILL pressed down
        hover_jump
        return
      end
      return  if (@has_jumped)
      if (bottom_is_touching_safe_block? @jump_standing_on_block_padding)
        @is_jumping = true
        @has_jumped = true
        add_velocity y: -@speed[:y], quick_turn_around: true
      end
    end

    def hover_jump
      y_velocity = get_velocity :y
      return  if (
        (y_velocity > 0) ||
        (y_velocity * -1) < @settings.get(:hover_jump_threshold)
      )
      speed = @settings.get :hover_jump_speed
      # NOTE:
      # We use Deltatime here for the velocity, because a lower
      # frame rate calls this method less often.
      add_velocity y: (-speed * @velocity_deltatime.dt), quick_turn_around: false
    end

    def bottom_is_touching_block? padding = 1
      previous_position = get_position.dup
      set_position y: (y + padding)
      standing_on_block = in_collision?
      set_position previous_position
      return standing_on_block
    end

    def top_is_touching_block? padding = 1
      previous_position = get_position.dup
      set_position y: (y - padding)
      standing_on_block = in_collision?
      set_position previous_position
      return standing_on_block
    end

    def bottom_is_touching_safe_block? padding = 1
      previous_position = get_position.dup
      set_position y: (y + padding)
      standing_on = get_colliding_objects
      set_position previous_position
      return standing_on.any? && standing_on.all?(&:is_safe?)
    end

    # NOTE:
    # The #is_touching_* methods only work if the Player's origin is centered (both axes).
    def is_touching_safe_block? padding = 1
      previous_size = get_size.dup
      set_size width: (get_size(:width) + (padding * 2)), height: (get_size(:height) + (padding * 2))
      standing_on = get_colliding_objects
      set_size previous_size
      safe_blocks = standing_on.select &:is_safe?
      return (safe_blocks.any? ? safe_blocks : false)
    end

    def is_touching_unsafe_block? padding = 1
      previous_size = get_size.dup
      set_size width: (get_size(:width) + (padding * 2)), height: (get_size(:height) + (padding * 2))
      standing_on = get_colliding_objects
      set_size previous_size
      unsafe_blocks = standing_on.select &:is_unsafe?
      return (unsafe_blocks.any? ? unsafe_blocks : false)
    end

    # NOTE:
    # We use Deltatime for the move_* methods, because a lower
    # frame rate calls these methods less often.
    def move_left
      add_velocity x: (-@speed[:x] * @velocity_deltatime.dt)
    end

    def move_right
      add_velocity x: (@speed[:x] * @velocity_deltatime.dt)
    end

    def touching_unsafe_block
      GAME.game_over
    end

    def hit_ceiling
      set_velocity y: 0
    end
end
