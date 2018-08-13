module Buttons
  class MainLevelSelect < AdventureRL::Button
    def setup
      set_position y: (AdventureRL::Window.get_window.get_side(:bottom) * @settings.get(:y))
      set_text 'Select Level'
    end
  end
end
