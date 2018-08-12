class Level < AdventureRL::Layer
  MOVE_INTERVAL_ID = :move
  CONFIG_FILE_NAME = 'level.json'
  ACTIVE_SECTIONS_AMOUNT = 2

  def setup settings = {}
    load_data_from_directory settings.get(:directory)
    @last_loaded_section_index = -1
    @timer = AdventureRL::TimingHandler.new
    add @timer
  end

  def play
    add_next_section
    set_interval
  end

  def add_next_section
    #[(ACTIVE_SECTIONS_AMOUNT - get_objects.size), 0].max.times do
    last_section = @sections[@last_loaded_section_index]  if     (@last_loaded_section_index >= 0 && @last_loaded_section_index < @sections.size)
    @last_loaded_section_index += 1
    return                                                unless (@last_loaded_section_index < @sections.size)
    new_section = @sections[@last_loaded_section_index]
    puts "LAST: #{last_section.get_id}"  if (last_section)
    puts "LOAD: #{new_section.get_id}"
    puts "EQUAL: #{new_section == last_section}"
    new_section.set_position((last_section || self).get_corner(:right, :top))  # NOTE: Adjust if Sections should move into different direction
    add new_section, new_section.get_id
    #end

    # TODO
    #@active_sections.shift([@active_sections.size - ACTIVE_SECTIONS_AMOUNT, 0].max)
  end

  def remove_section section
    remove_object section.get_id
  end

  def move_sections
    get_objects.each do |object|
      object.move  if (object.is_a? Section)
    end
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
            @config.get(:section)
          ).merge(
            level:    self,
            filename: basename,
            position: get_corner(:right, :top)
          )
        )
        if (@config.get(:final_section).sub(/\.json\z/i,'') == basename.sub(/\.json\z/i, ''))
          final_section = section
        else
          @sections << section
        end
      end
      sort_sections
      @sections << final_section
      @sections.compact!
    end

    def sort_sections
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
          section = @sections.sample.dup
          section.generate_id
          next section
        end
      when 'shuffle'
        @sections.shuffle!
      end
    end

    def set_interval
      @timer.every(
        id:      MOVE_INTERVAL_ID,
        seconds: @settings.get(:move_interval),
        method:  method(:move_sections)
      )
    end
end
