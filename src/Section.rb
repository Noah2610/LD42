class Section < AdventureRL::Layer
  def setup settings = {}
    @block_settings = settings.get(:blocks).map(&:keys_to_sym)
    @filename       = settings.get :filename
    @move_direction = settings.get :move_direction
    @move_speed     = settings.get :move_speed
    @deltatime      = AdventureRL::Deltatime.new
  end

  def get_filename
    return @filename
  end

  def set_layer layer
    super
    add_blocks
  end

  def update
    move
    super
    @deltatime.update
  end

  private

    def move
      move_by(
        ((@move_speed[:x] * @move_direction[:x]) * @deltatime.dt),
        ((@move_speed[:y] * @move_direction[:y]) * @deltatime.dt)
      )
    end

    def add_blocks
      @block_settings.each do |block_data|
        data = block_data.keys_to_sym
        classname = data[:class]
        clazz = Blocks.const_get classname
        settings = Blocks::Block.parse_settings(data)
        add clazz.new(settings), :block
      end
    end
end
