class Game < AdventureRL::Window
  DIGEST = {
    MD5: OpenSSL::Digest.new('MD5')
  }

  def setup settings
    @settings = settings
    setup_buttons_event_handler
    setup_menus
    setup_level_manager
    # @menu.activate  # NOTE: We activate it by default in settings.yml

    @current_level_name = 'dev'

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.5 do
      puts Gosu.fps
    end
    add @timer
  end

  def get_timer
    return @timer
  end

  def start_game level_name = @current_level_name
    @current_level_name = level_name
    setup_player
    @level_manager.load_level @current_level_name
    @level_manager.add_player @player
    @level_manager.play
    @player.add_to_solids_manager @level_manager.get_level.get_solids_manager
  end

  def continue_level
    @menus[:pause].deactivate  if (@level_manager.continue)
  end

  def pause_level
    @menus[:pause].activate  if (@level_manager.pause)
  end

  def stop_level
    @level_manager.stop
  end

  def reset_level
    stop_level
    start_game
  end

  def get_level
    return @level_manager.get_level
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
    @level_manager.button_down btnid
    #@menu.button_down btnid   if (@menu)
    #@player.button_down btnid
  end
  def button_up btnid
    super
    # TODO
    # Call #button_up on LevelManager
    @level_manager.button_up btnid
    #@menu.button_up btnid   if (@menu)
    #@player.button_up btnid
  end

  private

    def setup_buttons_event_handler
      #@buttons_event_handler = AdventureRL::EventHandlers::Buttons.new @settings.get(:buttons_event_handler)
      #@buttons_event_handler.subscribe self
    end

    def setup_level_manager
      @level_manager = LevelManager.new @settings.get(:level)
      add @level_manager
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
