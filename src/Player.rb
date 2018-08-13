class Player < AdventureRL::Animation
  include AdventureRL::Modifiers::Solid
  include AdventureRL::Modifiers::Velocity
  include AdventureRL::Modifiers::Gravity

  def setup settings
    setup_buttons_event_handler

    @speed = settings.get(:speed)
    @jump_standing_on_block_padding = settings.get(:jump_standing_on_block_padding)

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.01, method: method(:update_interval)
    @timer.every seconds: 0.02, method: method(:update_unsafe_collision)

    @is_jumping = false
    @has_jumped = false
    @has_won    = false

    load_animations
  end

  def win_level
    @buttons_event_handler.unsubscribe self
    @velocity_decay[:x] = 0
    @gravity_force = 0
    remove_from_solids_manager
    set_solid_tags nil
    set_solid_tags_collides_with nil
    @solids_manager = nil
    set_velocity(
      x: 100,
      y: 0
    )
    @is_jumping = false
    @has_won = true
  end

  def get_deltatime
    return @velocity_deltatime
  end

  def button_down btnid
    @buttons_event_handler.button_down btnid
  end
  def button_up btnid
    @buttons_event_handler.button_up btnid
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

  def update_interval
    move
    update_animation
    if (@has_won)
      GAME.open_win_menu  if (get_real_side(:right) > get_layer.get_real_side(:right))
    else
      layer = get_layer
      set_position(
        x: (layer.get_real_side(:right) - (get_size(:width) * 0.5).ceil)
      )  if (get_real_side(:right) > layer.get_real_side(:right))
    end
    if (@is_jumping)
      @is_jumping = false    if (bottom_is_touching_block?)
      hit_ceiling            if (get_velocity(:y) < 0 && top_is_touching_block?)
    end
    @buttons_event_handler.update
  end

  def update_animation
    if    (@is_jumping)
      set_animation :jumping
    elsif (get_velocity(:x).abs > 0)
      set_animation :moving
    else
      set_animation :idle
    end
    super
  end

  def update_unsafe_collision
    touching_unsafe_block  if (
      is_touching_unsafe_block? ||
      get_real_side(:top) > get_layer.get_real_side(:bottom)
    )
  end

  def update
    @timer.update
  end

  def draw
    scale =  1
    scale = -1  if (get_velocity(:x) < 0)
    Gosu.scale scale, 1, x, y do
      super
    end
  end

  private

    def load_animations
      animations_data = @settings.get(:animations)
      @animations = animations_data.map do |name, data|
        files = [data[:files]].flatten.map do |filename|
          next DIR[:images].join(filename)
        end
        next [name, {
          images:    get_images_from(files),
          intervals: [data[:intervals]].flatten
        }]
      end .to_h
      set_animation :idle
    end

    def set_animation name
      return  if (@current_animation == name)
      @current_animation = name
      @images              = @animations[name][:images]
      @animation_intervals = @animations[name][:intervals]
      @current_image_index = 0
    end

    def setup_buttons_event_handler
      @buttons_event_handler = AdventureRL::EventHandlers::Buttons.new @settings.get(:buttons_event_handler)
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
