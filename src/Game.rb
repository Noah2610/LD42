class Game < AdventureRL::Window
  DIGEST = {
    MD5: OpenSSL::Digest.new('MD5')
  }

  def setup settings
    @settings = settings
    setup_buttons_event_handler
    setup_menus
    # @menu.activate  # NOTE: We activate it by default in settings.yml

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.5 do
      puts Gosu.fps
    end
    add @timer
  end

  def start_game
    # TODO: Manage by LevelManager
    setup_player
    setup_level
    add @level
    @level.add @player, :player
    @level.play
    @player.add_to_solids_manager @level.get_solids_manager
  end

  def continue_level
    return  if (@level.is_playing?)
    @menus[:pause].deactivate
    @timer.in seconds: 0.01, method: @level.method(:continue)
  end

  def pause_level
    return  if (@level.is_paused?)
    @level.pause
    @menus[:pause].activate
  end

  def stop_level
    remove @level   if (@level)
    remove @player  if (@player)
  end

  def reset_level
    stop_level
    start_game
  end

  def get_level
    return @level
  end

  def get_menu target = :all
    return @menus          if (target == :all)
    return @menus[target]  if (@menus.key? target)
    return nil
  end

  def game_over
    puts 'GAME OVER'
  end

  def quit
    close
  end

  # TODO: Cleanup, Menus::Main handles :quit button, Game doesn't use a EventHandlers::Buttons anymore.
  def on_button_down btn
    close  if (btn == :quit)
  end

  def button_down btnid
    super
    # TODO
    # Call #button_down on LevelManager
    @level.button_down btnid  if (@level)
    #@menu.button_down btnid   if (@menu)
    #@player.button_down btnid
  end
  def button_up btnid
    super
    # TODO
    # Call #button_up on LevelManager
    @level.button_up btnid  if (@level)
    #@menu.button_up btnid   if (@menu)
    #@player.button_up btnid
  end

  private

    def setup_level
      load_level DIR[:levels].join(@settings.get(:level_name))
    end

    def load_level directory
      level_settings = @settings.get(:level).merge(
        directory: directory,
        position:  get_corner(:left, :top),
        size:      get_size
      )
      @level = Level.new level_settings
    end

    def setup_buttons_event_handler
      #@buttons_event_handler = AdventureRL::EventHandlers::Buttons.new @settings.get(:buttons_event_handler)
      #@buttons_event_handler.subscribe self
    end

    def setup_player
      settings = @settings.get(:player)
      settings[:files] = [settings[:files]].flatten.map do |file|
        next DIR[:images].join(file).to_path
      end
      settings[:position] = get_center
      @player = Player.new settings
    end

    def setup_menus
      @menus = {}
      @menus[:main] = Menus::Main.new({
        position: get_corner(:left, :top),
        size:     get_size
      }.merge(
        @settings.get(:main_menu)
      ))
      @menus[:pause] = Menus::Pause.new({
        position: get_corner(:left, :top),
        size:     get_size
      }.merge(
        @settings.get(:pause_menu)
      ))
      # TODO: Init other Menus here.
      @menus.values.each do |menu|
        add menu
      end
    end
end
