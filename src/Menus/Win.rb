module Menus
  class Win < AdventureRL::Menu
    def setup
      @buttons_settings = SETTINGS.get :menu_buttons
      @buttons_event_handler = AdventureRL::EventHandlers::Buttons.new @settings.get(:buttons_event_handler)
      @buttons_event_handler.subscribe self
      @buttons = {}
      add_buttons
      setup_title
    end

    def on_button_down btn
      case btn
      when :next
        @buttons[:next].click
      when :to_main
        @buttons[:to_main].click
      end
    end

    def button_down btnid
      super
      return  if (is_inactive?)
      @buttons_event_handler.button_down btnid
    end
    def button_up btnid
      super
      return  if (is_inactive?)
      @buttons_event_handler.button_up btnid
    end

    private

      def add_buttons
        get_buttons.each do |name, button|
          @buttons[name] = button
          add_button button
        end
      end

      def get_buttons
        return {
          next:    Buttons::WinNext.new(@buttons_settings.merge(@settings.get(:next))),
          to_main: Buttons::WinToMain.new(@buttons_settings.merge(@settings.get(:to_main)))
        }
      end

      def setup_title
        settings = @settings.get(:title_image)
        title = AdventureRL::Image.new(settings.merge(
          file: DIR[:images].join(settings[:file])
        ))
        title.set_position(
          (AdventureRL::Window.get_window.get_side(:right)  * settings[:x]),
          (AdventureRL::Window.get_window.get_side(:bottom) * settings[:y])
        )
        add title
      end
  end
end
