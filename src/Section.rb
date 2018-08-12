class Section < AdventureRL::Layer
  def setup settings = {}
    @block_settings = settings.get(:blocks).map(&:keys_to_sym)
    @level          = settings.get :level
    @filename       = settings.get :filename
    @move_direction = settings.get :move_direction
    @move_speed     = settings.get :move_speed
    generate_id
    # TODO: Remove Deltatime (?)
    @deltatime      = AdventureRL::Deltatime.new
    @timer          = AdventureRL::TimingHandler.new

    @added_next_section = false

    # TODO
    $first_id = get_id  unless ($first_id)
  end

  def generate_id
    chr_ids = (32 .. 126).to_a.shuffle
    @id = Game::DIGEST[:MD5].hexdigest(
      "#{@settings.to_s}_#{10000.times.map do
        next chr_ids.sample.chr
      end .join('')}"  # NOTE: Add some random printable characters, to make the id virtually unique
    )
  end

  def get_filename
    return @filename
  end

  def set_layer layer
    super
    add_blocks
    #set_interval
    @timer.reset
  end

  def get_id
    return "section_#{@id}"
  end

  def move
    check_collision  if (move_by(
      ((@move_speed[:x] * @move_direction[:x])),
      ((@move_speed[:y] * @move_direction[:y]))
    ))
  end

  def update
    super
    @timer.update
    @deltatime.update
  end

  private

    def set_interval
      @timer.every(
        id:      MOVE_INTERVAL_ID,
        seconds: 0.05,
        method:  method(:move)
      )
    end

    def check_collision
      # NOTE:
      # Will need to adjust this code,
      # if we decide to make the Sections move into a different direction.
      if (get_side(:left) <= @level.get_side(:left))
        unless (@added_next_section)
          @level.add_next_section
          @added_next_section = true
        end
        @level.remove_section self  if (get_side(:right) < @level.get_side(:left))
      end
    end

    def add_blocks
      @block_settings.each do |block_data|
        data = block_data.keys_to_sym
        classname = data[:class]
        clazz = Blocks.const_get classname
        block = clazz.new(Blocks::Block.parse_settings(data))
        add block, :block
        block.add_to_solids_manager get_solids_manager
        #get_solids_manager.add block
      end
    end
end
