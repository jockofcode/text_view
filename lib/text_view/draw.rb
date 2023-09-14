require 'curses'

module TextView
  module Draw
    def self.debug_log(message)
      if ENV['DEBUG_LOG']
        caller_info = caller_locations(1,1).first
        method_name = caller_info.label
        line_number = caller_info.lineno

        File.open('debug.log', 'a') do |f|
          f.puts("#{Time.now} window:#{@window_number} #{message} - Method: #{method_name}, Line: #{line_number}")
        end
      end
    end
    def self.line(x1, y1, x2, y2,char_color,bg_color)
      points = []
      dx = x2 - x1
      dy = y2 - y1
      dx1 = dx.abs
      dy1 = dy.abs
      twody1 = 2 * dy1
      twody1_minus_dx1 = twody1 - dx1
      twody1_plus_dx1 = twody1 + dx1

      if dy1 <= dx1
        if dx >= 0
          x = x1
          y = y1
          xe = x2
        else
          x = x2
          y = y2
          xe = x1
        end

        points << [y, x, '*']

        for _ in x..xe
          x += 1
          if twody1_minus_dx1 >= 0
            y += 1 if dy >= 0
            y -= 1 if dy < 0
            twody1_minus_dx1 -= 2 * dx1
          end
          twody1_minus_dx1 += 2 * dy1
          points << [y, x, '*']
        end
      else
        twody1 = dy1 << 1
        twody1_minus_dx1 = twody1 - dx1
        twody1_plus_dx1 = twody1 + dx1

        if dy >= 0
          x = x1
          y = y1
          ye = y2
        else
          x = x2
          y = y2
          ye = y1
        end

        points << [y, x, '*']

        for _ in y..ye
          y += 1
          if twody1_minus_dx1 >= 0
            x += 1 if dx >= 0
            x -= 1 if dx < 0
            twody1_minus_dx1 -= 2 * dx1
          end
          twody1_minus_dx1 += 2 * dy1
          points << [y, x, '*',char_color,bg_color]
        end
      end

      points
    end

    def self.circle(x1, y1, x2, y2,char_color,bg_color)
      points = []

      # Calculate the center using the midpoint formula
      center_x = (x1 + x2) / 2.0
      center_y = (y1 + y2) / 2.0

      # Calculate the radius based on the distance formula
      radius = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2) / 2.0

      # Calculate the circumference of the circle in characters
      circumference = 2 * Math::PI * radius

      # Determine the granularity (step angle) based on the circumference
      num_points = circumference.ceil

      # Calculate the step angle based on the number of points
      step_angle = (2 * Math::PI) / num_points

      # Loop through the circle by angle from 0 to 2*PI
      (0..num_points).each do |i|
        radian = i * step_angle
        x = center_x + (radius * Math.cos(radian)).round
        y = center_y + (radius * Math.sin(radian)).round

        # Adjust x-coordinate to handle terminal aspect ratio
        adjusted_x = (2 * x).round
        points << [y, adjusted_x, 'o',char_color,bg_color]
      end

      points
    end

    # Draw a rectangle with top-left point (x1, y1) and bottom-right point (x2, y2)
    def self.rectangle(x1, y1, x2, y2,char_color,bg_color)
      debug_log "rectangle x1: #{x1}, y1: #{y1}, x2: #{x2}, y2: #{y2}"
      points = []

      # Top and bottom edges
      (x1..x2).each do |x|
        points << [y1, x, '-',char_color,bg_color]
        points << [y2, x, '-',char_color,bg_color]
      end

      # Left and right edges
      (y1..y2).each do |y|
        points << [y, x1, '|',char_color,bg_color]
        points << [y, x2, '|',char_color,bg_color]
      end

      # Corners
      points << [y1, x1, '+',char_color,bg_color]
      points << [y1, x2, '+',char_color,bg_color]
      points << [y2, x1, '+',char_color,bg_color]
      points << [y2, x2, '+',char_color,bg_color]

      points
    end
  end
end
