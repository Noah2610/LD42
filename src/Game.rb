class Game < AdventureRL::Window
  def setup settings
    setup_buttons_event_handler settings.get(:buttons)
    setup_player settings.get(:player)

    # TODO: tmp
    @blocks = [
      Blocks::Safe.new(settings.get(:block).merge(
        file: DIR[:images].join(settings.get(:block)[:file]),
        position: {
          x: get_center(:x),
          y: get_size(:height) * 0.75
        }
      ))
    ]
    @blocks.each do |block|
      add block
    end

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.5 do
      puts Gosu.fps
    end
    add @timer
  end

  def on_button_down btn
    close  if (btn == :quit)
  end

  private

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
