require 'curses'

module TextView
  module CursesDraw

    def initialize(parent = nil)
      super
      init_screen
      init_colors
    end

    def init_colors
      if Curses.can_change_color?
        Curses.init_color(Curses::COLOR_BLACK, 0, 0, 0)
        Curses.init_color(Curses::COLOR_BLUE, 0, 0, 1000)
        Curses.init_color(Curses::COLOR_CYAN, 0, 1000, 1000)
        Curses.init_color(Curses::COLOR_GREEN, 0, 1000, 0)
        Curses.init_color(Curses::COLOR_MAGENTA, 1000, 0, 1000)
        Curses.init_color(Curses::COLOR_RED, 1000, 0, 0)
        Curses.init_color(Curses::COLOR_WHITE, 1000, 1000, 1000)
        Curses.init_color(Curses::COLOR_YELLOW, 1000, 1000, 0)
      end
    end

    def init_screen
      super
      Curses.start_color
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.stdscr.keypad(true)
      Curses.timeout = 0 # Non-blocking input
      Curses.clear
    end

    def destroy_screen
      super
      Curses.close_screen
    end


    def screen_width
      Curses.cols
    end

    def screen_height
      Curses.lines
    end

    def getc = Curses.getch

    def map_color(symbol)
      case symbol
      when :black
        Curses::COLOR_BLACK
      when :blue
        Curses::COLOR_BLUE
      when :cyan
        Curses::COLOR_CYAN
      when :green
        Curses::COLOR_GREEN
      when :magenta
        Curses::COLOR_MAGENTA
      when :red
        Curses::COLOR_RED
      when :white
        Curses::COLOR_WHITE
      when :yellow
        Curses::COLOR_YELLOW
      else
        Curses::COLOR_WHITE # Default color
      end
    end

    def initialize_color_pair(char_color, bg_color)
      pair_key = "#{char_color}_#{bg_color}"

      unless @@color_pairs[pair_key]
        pair_id = @@color_pairs.size + 1
        Curses.init_pair(pair_id, char_color, bg_color)
        @@color_pairs[pair_key] = pair_id
      end

      @@color_pairs[pair_key]
    end

    def draw_char(line, column, char, char_color, bg_color)

      char_color = map_color(char_color)
      bg_color = map_color(bg_color)

      color_pair_id = initialize_color_pair(char_color, bg_color)

      Curses.attron(Curses.color_pair(color_pair_id)) do
        Curses.setpos(line + absolute_pos_y, column + absolute_pos_x)
        Curses.addstr(char)
      end
      # debug_log("drew #{char} on line #{line}, column #{column}, in #{char_color} on #{bg_color}")
    end
    def map_color(symbol)
      case symbol
      when :black
        Curses::COLOR_BLACK
      when :blue
        Curses::COLOR_BLUE
      when :cyan
        Curses::COLOR_CYAN
      when :green
        Curses::COLOR_GREEN
      when :magenta
        Curses::COLOR_MAGENTA
      when :red
        Curses::COLOR_RED
      when :white
        Curses::COLOR_WHITE
      when :yellow
        Curses::COLOR_YELLOW
      else
        Curses::COLOR_WHITE # Default color
      end
    end
  end
end
