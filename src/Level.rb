class Level < AdventureRL::Layer
  CONFIG_FILE_NAME = 'level.json'
  ACTIVE_SECTIONS_AMOUNT = 2

  def setup settings = {}
    load_data_from_directory settings.get(:directory)
    @last_loaded_section_index = -1
    @active_sections = []

    # TODO
    @buttons = AdventureRL::EventHandlers::Buttons.new auto_update: true
    @buttons.add_pressable_button(
      left:  :x,
      right: :c
    )
  end

  def update
    # TODO
    super
    @buttons.update
  end

  def play
    add_next_section
  end

  private

    def load_data_from_directory dir
      directory = Pathname.new dir
      @config   = AdventureRL::Settings.new directory.join(CONFIG_FILE_NAME)
      load_sections_from_directory directory
    end

    def load_sections_from_directory dir
      directory     = Pathname.new dir
      @sections     = []
      final_section = nil
      directory.each_child do |file|
        basename = file.basename.to_s
        next  if     (basename == CONFIG_FILE_NAME)
        next  unless (basename.match?(/\.json\z/i))
        section = Section.new(
          AdventureRL::Settings.new(
            SETTINGS.get(:section)
          ).merge(
            AdventureRL::Settings.new(file)
          ).merge(
            filename: basename
          )
        )
        if (@config.get(:final_section).sub(/\.json\z/i,'') == basename.sub(/\.json\z/i, ''))
          final_section = section
        else
          @sections << section
        end
      end
      case section_order = @config.get(:section_order)
      when Array
        @sections = @sections.select do |section|
          next section_order.include?(section.get_filename)
        end .sort_by_array(section_order)
      when 'alphanumerical'
        @sections.sort! do |section_one, section_two|
          next section_one.get_filename <=> section_two.get_filename
        end
      when 'random'
        @sections = @config.get(:section_count).times.map do
          next @sections.sample
        end
      when 'shuffle'
        @sections.shuffle!
      end
      @sections << final_section
      @sections.compact!
    end

    def add_next_section
      @last_loaded_section_index += 1
      return  unless (@last_loaded_section_index < @sections.size)
      section = @sections[@last_loaded_section_index]
      add section, "section_#{section.get_filename}"

      # TODO
      @buttons.subscribe section

      @active_sections << section
      @active_sections.shift([@active_sections.size - ACTIVE_SECTIONS_AMOUNT, 0].max)
    end
end
