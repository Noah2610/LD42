module Buttons
  class DeathToMain < AdventureRL::Button
    def setup
      set_position(
        (AdventureRL::Window.get_window.get_side(:right)  * @settings.get(:x)),
        (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      )
      set_text @settings.get(:text)
    end

    def click
      #get_menu.deactivate  # NOTE: Not necessary, Game#to_main_menu deactivates all Menus
      GAME.to_main_menu
    end
  end
end
