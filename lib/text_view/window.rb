
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
    def self.included_features = @@included_features

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

    def parent
      @parent
    end

    def initialize(parent = nil)
      @@included_features.each do |feature|
        self.class.include feature
      end
      @@window_number += 1
      @parent = parent
      @window_number = @@window_number
      @children = []
      @message_registry = {}
      @parent.register_child(self) if @parent
      @render_queue = Queue.new
      @message_queue = Queue.new
      init_window_dimensions
      debug_log("Initialized window #{@window_number}")
    end

    def screen_width
        begin
          rows, cols = IO.console.winsize
          cols
        rescue NoMethodError
          80
        end
    end

    def screen_height
        begin
          rows, cols = IO.console.winsize
          rows
        rescue NoMethodError
          25
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
        @width = screen_width
        @height = screen_height
        @pos_x = 0
        @pos_y = 0
      end
      debug_log "w: #{@width}, h: #{@height}, x: #{@pos_x}, y: #{pos_y}"
    end

    def init_screen
    end

    def destroy_screen
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

    def trim_to_window(line, column, char)
      if char.is_a?(String)
        remaining_space = @width - column
        char = char.slice(0, remaining_space)
      end
    end
    def draw_char(line, column, char, char_color, bg_color)
      return unless in_window?(line, column)
      trim_to_window(line,column,char)


      abs_line = line + absolute_pos_y
      abs_column = column + absolute_pos_x
      raw_draw_char(abs_line, abs_column, char, char_color, bg_color)
    end

    def raw_draw_char(abs_line, abs_column, char, char_color, bg_color)
      print "\033[#{abs_line + 1};#{abs_column + 1}H#{char}"
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

    def getc
      @@char_input ||= Thread.new do
        @input_char = nil
        loop do
          @input_char = $stdin.getch
        end
      end
      c = @input_char
      @input_char = nil
      c
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
        key = getc
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

      destroy_screen
    end
  end
end
