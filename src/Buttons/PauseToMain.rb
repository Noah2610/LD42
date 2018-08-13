module Buttons
  class PauseToMain < AdventureRL::Button
    def setup
      set_position(
        (AdventureRL::Window.get_window.get_side(:right)  * @settings.get(:x)),
        (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      )
      set_text @settings.get(:text)
    end

    def click
      get_menu.deactivate
      GAME.stop_level
      GAME.get_menu(:main).activate
    end
  end
end
