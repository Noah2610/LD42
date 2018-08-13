class LevelManager
  def initialize settings = {}
    @settings = settings
    @level = nil
  end

  def get_level
    return @level
  end

  def load_level level_name
    directory = DIR[:levels].join(level_name)
    level_settings = @settings.merge(
      directory: directory,
      position:  GAME.get_corner(:left, :top),
      size:      GAME.get_size
    )
    @level = Level.new level_settings
  end

  def play
    @level.play  if (@level)
  end

  def stop
    #@level.remove :player
    @level = nil
  end

  def continue
    return false  if (@level.is_playing?)
    GAME.get_timer.in seconds: 0.01, method: @level.method(:continue)
    return true
  end

  def pause
    return false  if (@level.is_paused?)
    @level.pause
    return true
  end

  def add_player object
    @level.add object, :player  if (@level)
  end

  def update
    @level.update  if (@level)
  end

  def draw
    @level.draw  if (@level)
  end

  def button_down btnid
    @level.button_down btnid  if (@level)
  end
  def button_up btnid
    @level.button_up btnid  if (@level)
  end
end
