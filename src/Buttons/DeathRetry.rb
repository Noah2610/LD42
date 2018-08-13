module Buttons
  class DeathRetry < AdventureRL::Button
    def setup
      set_position(
        (AdventureRL::Window.get_window.get_side(:right)  * @settings.get(:x)),
        (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      )
      set_text @settings.get(:text)
    end

    def click
      get_menu.deactivate
      GAME.reset_level
    end
  end
end
