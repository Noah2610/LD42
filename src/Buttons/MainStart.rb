module Buttons
  class MainStart < AdventureRL::Button
    def setup
      set_position y: (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      set_text 'Start Game'
    end

    def on_button_down btn
      click  if ([:kb_return, :kb_enter].include? btn)
    end

    def click
      get_menu.deactivate
      GAME.start_game
    end
  end
end
