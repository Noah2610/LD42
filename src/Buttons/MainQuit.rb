module Buttons
  class MainQuit < AdventureRL::Button
    def setup
      set_position y: (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      set_text 'Quit'
    end
  end
end
