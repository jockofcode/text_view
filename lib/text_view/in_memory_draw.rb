module InMemoryDraw
  attr_reader :in_memory_draw_buffer

  def initialize(*args)
    super
    @in_memory_draw_buffer = Array.new(height) { Array.new(width, ' ') }
  end

  def draw_char(line, column, char, _char_color = nil, _bg_color = nil)
    return unless in_window?(line, column)
    trim_to_window(line, column, char)

    abs_line = line + absolute_pos_y
    abs_column = column + absolute_pos_x

    @in_memory_draw_buffer[abs_line][abs_column] = char
  end

  def read_char(line, column)
    abs_line = line + absolute_pos_y
    abs_column = column + absolute_pos_x

    @in_memory_draw_buffer[abs_line][abs_column]
  end
  module InMemoryDraw
    attr_reader :in_memory_draw_buffer

    def initialize(*args)
      super
      @in_memory_draw_buffer = Array.new(height) { Array.new(width, ' ') }
    end

    def raw_draw_char(abs_line, abs_column, char, _char_color = nil, _bg_color = nil)
      @in_memory_draw_buffer[abs_line][abs_column] = char
    end

    def raw_read_char(line, column)
      @in_memory_draw_buffer[line][column]
    end
  end

end
