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
    move
    @is_jumping = false  if (@is_jumping && is_standing_on_block?)
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
      if (is_standing_on_block? @jump_standing_on_block_padding)
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
      add_velocity y: -speed, quick_turn_around: false
    end

    def is_standing_on_block? padding = 1
      previous_position = get_position.dup
      set_position y: (y + padding)
      standing_on_block = in_collision?
      set_position previous_position
      return standing_on_block
    end

    def move_left
      add_velocity x: -@speed[:x]
    end

    def move_right
      add_velocity x: @speed[:x]
    end
end
