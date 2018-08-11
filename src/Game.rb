class Game < AdventureRL::Window
  def setup settings
    setup_buttons_event_handler settings.get(:buttons)
    setup_player settings.get(:player)

    block_settings        = settings.get(:block)
    safe_block_settings   = block_settings.merge(settings.get(:safe_block))
    safe_block_settings.merge!(
      file: DIR[:images].join(safe_block_settings[:file]),
      position: {
        x: get_center(:x),
        y: get_size(:height) * 0.75
      }
    )
    unsafe_block_settings = block_settings.merge(settings.get(:unsafe_block))
    unsafe_block_settings.merge!(
      file: DIR[:images].join(unsafe_block_settings[:file]),
      position: {
        x: get_center(:x),
        y: get_size(:height) * 0.75
      }
    )

    # TODO: tmp
    @blocks = [
      Blocks::Safe.new(safe_block_settings.merge(
        position: {
          x: (get_side(:right)  * 0.25),
          y: (get_side(:bottom) * 0.75),
        },
        size: {
          width:  (get_size(:width)  * 0.5),
          height: 16
        }
      )),
      50.times.map do
        next Blocks::Safe.new(safe_block_settings.merge(
          position: {
            x: (get_side(:left) .. get_side(:right)).sample,
            y: (get_side(:top)  .. get_side(:bottom)).sample,
          },
          size: {
            width:  (2 .. 32).sample,
            height: (2 .. 32).sample
          }
        ))
      end,
      20.times.map do
        next Blocks::Unsafe.new(unsafe_block_settings.merge(
          position: {
            x: (get_side(:left) .. get_side(:right)).sample,
            y: (get_side(:top)  .. get_side(:bottom)).sample,
          },
          size: {
            width:  (2 .. 32).sample,
            height: (2 .. 32).sample
          }
        ))
      end,
    ].flatten
    @blocks.each do |block|
      add block
    end

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 2 do
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
