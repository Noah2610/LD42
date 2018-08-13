class Game < AdventureRL::Window
  def setup settings
    @settings = settings
    setup_buttons_event_handler
    setup_menus
    setup_level_manager
    # @menu.activate  # NOTE: We activate it by default in settings.yml

    @level_names = @settings.get :level_names
    @current_level_name_index = 0

    textbox_settings = @settings.get(:thankyou_textbox)
    @thankyou_textbox = AdventureRL::Textbox.new(
      textbox_settings.merge(
        position: {
          x: (get_side(:right)  * textbox_settings[:x]),
          y: (get_side(:bottom) * textbox_settings[:y])
        }
      )
    )

    @background_image = AdventureRL::Image.new(
      @settings.get(:background_image).merge(
        file:     DIR[:images].join(@settings.get(:background_image)[:file]),
        position: get_corner(:left, :top),
        size:     get_size
      )
    )
    add @background_image, :background_image

    @song = Gosu::Song.new DIR[:audio].join(@settings.get(:song_file))

    @timer = AdventureRL::TimingHandler.new

    # TODO
    #@timer.every seconds: 0.5 do
    #  puts Gosu.fps
    #end
    add @timer
  end

  def get_timer
    return @timer
  end

  def start_game level_name_index = @current_level_name_index
    @song.play !!:loop  unless (@song.playing?)
    remove :background_image
    remove :thankyou
    level_name = @level_names[@current_level_name_index]
    setup_player
    @level_manager.load_level level_name
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

  def to_main_menu
    @song.stop
    add @background_image, :background_image
    stop_level
    @menus.values.each &:deactivate
    @menus[:main].activate
  end

  def win_level
    @player.win_level
  end

  def open_win_menu
    @menus.values.each &:deactivate
    @menus[:win].activate
  end

  def next_level
    @current_level_name_index += 1
    if (@current_level_name_index >= @level_names.size)
      @current_level_name_index = 0
      add @thankyou_textbox, :thankyou
      to_main_menu
      return
    end
    reset_level
  end

  def game_over
    @level_manager.pause
    @menus[:death].activate
  end

  def quit
    close
  end

  def on_button_down btn
    toggle_mute  if (btn == :toggle_music)
  end

  def toggle_mute
    return  unless (@song)
    if (@song.playing?)
      @song.stop
    else
      @song.play
    end
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
      @buttons_event_handler = AdventureRL::EventHandlers::Buttons.new @settings.get(:buttons_event_handler)
      @buttons_event_handler.subscribe self
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
      @menus[:death] = Menus::Death.new({
        position: get_corner(:left, :top),
        size:     get_size
      }.merge(
        @settings.get(:death_menu)
      ))
      @menus[:win] = Menus::Win.new({
        position: get_corner(:left, :top),
        size:     get_size
      }.merge(
        @settings.get(:win_menu)
      ))
      @menus.values.each do |menu|
        add menu
      end
    end
end
