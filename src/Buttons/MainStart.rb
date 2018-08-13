module Buttons
  class MainStart < AdventureRL::Button
    def setup
      set_position y: (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      set_text @settings.get(:text)
    end

    def click
      get_menu.deactivate
      GAME.start_game
    end
  end
end
