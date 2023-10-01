require 'curses'

module TextView
  module Error
    ONLY_ROOT_WINDOW_CAN_RUN = "Only the root window can run the application"
  end
end

module TextView
  class Window
    @@window_number = 0
    @@color_pairs = {}
    attr_accessor :width, :height, :pos_x, :pos_y

    @@included_features = []

    def self.include_feature(feature_module) = @@included_features << feature_module
    def included_features = @@included_features + @included_features
    def self.included_features = @@included_features

    def include_feature(feature_module)
      @included_features << feature_module
      include feature_module
    end

    def debug_log(message)
      if ENV['DEBUG_LOG']
        caller_info = caller_locations(1,1).first
        method_name = caller_info.label
        line_number = caller_info.lineno

        File.open('debug.log', 'a') do |f|
          f.puts("#{Time.now} window:#{@window_number} #{message} - Method: #{method_name}, Line: #{line_number}")
        end
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

    def parent
      @parent
    end

    def initialize(parent = nil)
      @@included_features.each do |feature|
        self.class.include feature
      end
      @included_features = []
      @@window_number += 1
      @parent = parent
      @window_number = @@window_number
      @children = []
      @message_registry = {}
      @parent.register_child(self) if @parent
      init_screen
      init_window_dimensions
      init_colors
      @render_queue = Queue.new
      @message_queue = Queue.new
      debug_log("Initialized window #{@window_number}")
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

    def receive_message(message_type, *args)
      entries = @message_registry[message_type] || []
      entries.each do |entry|
        filter = entry[:args]
        next unless filter_matches?(filter, args)

        debug_log("calling #{entry}:#{args}")
        entry[:lambda].call
        debug_log "@quit_flag is #{@quit_flag}, I am window #{@window_number}"
      end
    end

    def filter_matches?(filter, args)
      return true if filter.nil? || filter == :all

      case filter
      when Range
        args.all? { |arg| filter.include?(arg) }
      when Array
        args.all? { |arg| filter.include?(arg) }
      else
        filter == args
      end
    end

    def register_message_type(message_type: nil, args: nil, &block)
      @message_registry[message_type] ||= []
      @message_registry[message_type] << { args: args, lambda: block }
      debug_log("message type #{message_type}:#{args} registered")
    end

    def unregister_message_type(message_type, args: nil)
      return unless @message_registry[message_type]

      @message_registry[message_type].reject! do |entry|
        args.nil? || entry[:args] == args
      end
    end

    def create_child
      child = self.class.new(self)
      register_child(child)
      child
    end

    def send_quit
      @parent.receive_message(:quit) if @parent
    end

    def register_child(child)
      @children << child
    end

    def dispatch_message(message_type, *args)
      @children.each { |child| child.receive_message(message_type, *args) }
    end

    def register_child(child)
      @children << child
    end

    def init_window_dimensions
      if @parent
        debug_log "(Child) assigning window dimensions"
        @width = @parent.width / 2
        @height = @parent.height / 2
        @pos_x = @parent.pos_x
        @pos_y = @parent.pos_y
      else
        debug_log "(Parent) assigning window dimensions"
        @width = Curses.cols
        @height = Curses.lines
        @pos_x = 0
        @pos_y = 0
      end
      debug_log "w: #{@width}, h: #{@height}, x: #{@pos_x}, y: #{pos_y}"
    end

    def init_screen
      Curses.start_color
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.stdscr.keypad(true)
      Curses.timeout = 0 # Non-blocking input
      Curses.clear
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

    def absolute_pos_x
      @parent ? @parent.absolute_pos_x + @pos_x : @pos_x
    end

    def absolute_pos_y
      @parent ? @parent.absolute_pos_y + @pos_y : @pos_y
    end

    def in_window?(line, column)
      # Convert to absolute coordinates
      abs_line = line + absolute_pos_y
      abs_column = column + absolute_pos_x

      current_window = self

      while current_window
        inside = abs_line.between?(current_window.absolute_pos_y, current_window.absolute_pos_y + current_window.height - 1) &&
          abs_column.between?(current_window.absolute_pos_x, current_window.absolute_pos_x + current_window.width - 1)

        if inside == false
          debug_log("y: #{abs_line}, x: #{abs_column} Not In Window. abs_y: #{current_window.absolute_pos_y}, abs_x: #{current_window.absolute_pos_x}")
          return false
        end

        current_window = current_window.parent
      end

      true
    end


    def draw_char(line, column, char, char_color, bg_color)
      # Truncate the string if its length exceeds the window's width
      if char.is_a?(String)
        remaining_space = @width - column
        char = char.slice(0, remaining_space)
      end

      char_color = map_color(char_color)
      bg_color = map_color(bg_color)

      color_pair_id = initialize_color_pair(char_color, bg_color)

      if in_window?(line, column)
        Curses.attron(Curses.color_pair(color_pair_id)) do
          Curses.setpos(line + absolute_pos_y, column + absolute_pos_x)
          Curses.addstr(char)
        end
        # debug_log("drew #{char} on line #{line}, column #{column}, in #{char_color} on #{bg_color}")
      else
        # debug_log("Not in window to draw #{char} on line #{line}, column #{column}")
      end
    end

    def draw(&block)
      debug_log("Start position: { x: #{@pos_x}, y: #{@pos_y} }, size: { w: #{@width}, h: #{@height} }")
      drawing_instructions = yield(@width, @height)

      drawing_instructions.each do |line, column, char, char_color, bg_color|
        add_to_render_queue { draw_char(line, column, char,char_color,bg_color) }
      end
    end

    def render
      until @render_queue.empty?
        render_lambda = @render_queue.deq
        render_lambda.call
      end

      @children.each{|child|
        child.render
      }
    end

    def add_to_render_queue(&block)
      @render_queue.enq(block)
    end

    def run
      if @parent
        raise TextView::Error::ONLY_ROOT_WINDOW_CAN_RUN
      end
      debug_log("In run loop")

      @quit_flag = false
      @loop_speed = 30
      @loop_pause = 1.0 / @loop_speed.to_f

      while !@quit_flag
        key = Curses.getch
        if key
          debug_log("keypress received: #{key}")
          @message_queue.enq({ message_type: :key_press, args: [key] })
        end

        # Simulated mouse movement for demonstration; replace with actual mouse movement
        mouse_x, mouse_y = [5, 5]
        @message_queue.enq({ message_type: :mouse_move, args: [mouse_x, mouse_y] })

        until @message_queue.empty?
          message = @message_queue.deq
          dispatch_message(message[:message_type], *message[:args])
        end

        render

        sleep @loop_pause
      end

      Curses.close_screen
    end

  end
end
