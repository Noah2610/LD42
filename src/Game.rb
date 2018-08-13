class Game < AdventureRL::Window
  DIGEST = {
    MD5: OpenSSL::Digest.new('MD5')
  }

  def setup settings
    @settings = settings
    setup_buttons_event_handler
    setup_main_menu

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.5 do
      puts Gosu.fps
    end
    add @timer
  end

  def start_game
    # TODO: Manage by LevelManager
    setup_player
    load_level DIR[:levels].join(@settings.get(:level_name))
    add @level
    @level.add @player, :player
    @level.play
    @player.add_to_solids_manager @level.get_solids_manager
  end

  def game_over
    puts 'GAME OVER'
  end

  def on_button_down btn
    close  if (btn == :quit)
  end

  def button_down btnid
    super
    # TODO
    # Call #button_down on LevelManager
    @level.button_down btnid  if (@level)
    #@player.button_down btnid
  end
  def button_up btnid
    super
    # TODO
    # Call #button_up on LevelManager
    @level.button_up btnid  if (@level)
    #@player.button_up btnid
  end

  private

    def load_level directory
      level_settings = @settings.get(:level).merge(
        directory: directory,
        position:  get_corner(:left, :top),
        size:      get_size
      )
      @level = Level.new level_settings
    end

    def setup_buttons_event_handler
      @buttons_event_handler = AdventureRL::EventHandlers::Buttons.new @settings.get(:buttons_event_handler)
      @buttons_event_handler.subscribe self
    end

    def setup_player
      settings = @settings.get(:player)
      settings[:files] = [settings[:files]].flatten.map do |file|
        next DIR[:images].join(file).to_path
      end
      settings[:position] = get_center
      @player = Player.new settings
    end

    def setup_main_menu
      @menu = Menus::Main.new({
        position: get_corner(:left, :top),
        size:     get_size
      }.merge(
        @settings.get(:main_menu)
      ))
      add @menu
    end
end
