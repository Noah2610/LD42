module Menus
  class Main < AdventureRL::Menu
    def setup
      @buttons_settings = SETTINGS.get :menu_buttons
      add_buttons
    end

    private

      def add_buttons
        get_buttons.each do |button|
          add_button button
        end
      end

      def get_buttons
        return [
          Buttons::MainStart.new(@buttons_settings.merge(@settings.get(:start))),
          Buttons::MainLevelSelect.new(@buttons_settings.merge(@settings.get(:level_select))),
          Buttons::MainQuit.new(@buttons_settings.merge(@settings.get(:quit)))
        ]
      end
  end
end
