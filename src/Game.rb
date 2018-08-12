class Game < AdventureRL::Window
  def setup settings
    @settings = settings
    setup_buttons_event_handler @settings.get(:buttons)
    setup_player @settings.get(:player)

    load_level DIR[:levels].join('dev')
    add @level
    @level.play
    @player.add_to_solids_manager @level.get_solids_manager

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.5 do
      puts Gosu.fps
    end
    add @timer
  end

  def on_button_down btn
    close  if (btn == :quit)
  end

  def game_over
    puts 'GAME OVER'
  end

  def button_down btnid
    super
    @player.button_down btnid
  end
  def button_up btnid
    super
    @player.button_up btnid
  end

  private

    def load_level directory
      level_settings = @settings.get(:level).merge(
        directory: directory,
        position:  get_corner(:right, :top),
        size:      get_size
      )
      @level = Level.new level_settings
    end

    def setup_buttons_event_handler settings = {}
      @buttons_event_handler = AdventureRL::EventHandlers::Buttons.new settings
      @buttons_event_handler.subscribe self
    end

    def setup_player settings = {}
      settings[:files] = [settings[:files]].flatten.map do |file|
        next DIR[:images].join(file).to_path
      end
      settings[:position] = get_center
      @player = Player.new settings
      add @player
    end
end
