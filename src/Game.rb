class Game < AdventureRL::Window
  def setup settings
    @settings = settings
    setup_buttons_event_handler @settings.get(:buttons)
    setup_player @settings.get(:player)

    load_level DIR[:levels].join('dev')
    add @level
    @level.play
    @player.add_to_solids_manager @level.get_solids_manager

    # TODO: tmp
=begin
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
      30.times.map do
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
      10.times.map do
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
=end

    @timer = AdventureRL::TimingHandler.new
    @timer.every seconds: 0.5 do
      puts Gosu.fps
    end
    #@timer.every seconds: 0.1, method: method(:move_blocks)
    add @timer
  end

  def move_blocks
    @blocks.each do |block|
      dir = {
        x: ((rand(2) == 0) ? 1 : -1),
        y: ((rand(2) == 0) ? 1 : -1),
      }
      block.move_by(
        x: (rand(1 .. 20) * dir[:x]),
        y: (rand(1 .. 20) * dir[:y])
        #x: (20 * dir[:x]),
        #y: (20 * dir[:y])
      )
    end
  end

  def on_button_down btn
    close  if (btn == :quit)
  end

  def game_over
    puts 'GAME OVER'
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
