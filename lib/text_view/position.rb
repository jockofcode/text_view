require 'curses'

module TextView
  module Position
    def set_right_of(other_window)
      old_pos = "{ y: #{self.pos_y}, x: #{self.pos_x} }"
      self.pos_x = other_window.pos_x + other_window.width
      self.pos_y = other_window.pos_y
      debug_log("old_position: #{old_pos}, position: y: #{self.pos_y}, x: #{self.pos_x}")
      self
    end

    def set_left_of(other_window)
      old_pos = "{ y: #{self.pos_y}, x: #{self.pos_x} }"
      self.pos_x = other_window.pos_x - self.width
      self.pos_y = other_window.pos_y
      debug_log("old_position: #{old_pos}, position: y: #{self.pos_y}, x: #{self.pos_x}")
      self
    end

    def set_below(other_window)
      old_pos = "{ y: #{self.pos_y}, x: #{self.pos_x} }"
      self.pos_x = other_window.pos_x
      self.pos_y = other_window.pos_y + other_window.height
      debug_log("old_position: #{old_pos}, position: y: #{self.pos_y}, x: #{self.pos_x}")
      self
    end

    def set_above(other_window)
      old_pos = "{ y: #{self.pos_y}, x: #{self.pos_x} }"
      self.pos_x = other_window.pos_x

      if other_window.pos_y < self.height
        # Move the other_window below self if there's not enough room above
        other_window.pos_y = self.pos_y + self.height
        self.pos_y = 0
      else
        self.pos_y = other_window.pos_y - self.height
      end

      debug_log("old_position: #{old_pos}, position: y: #{self.pos_y}, x: #{self.pos_x}")
      self
    end



    def set_remaining_width
      prev_width = self.width
      remaining_space = @parent.width - self.pos_x
      self.width = remaining_space
      debug_log("changed width from #{prev_width} to #{self.width}")
      self
    end

    def set_remaining_height
      prev_height = self.height
      remaining_space = @parent.height - self.pos_y
      self.height = remaining_space
      debug_log("changed height from #{prev_height} to #{self.height}")
      self
    end

    def set_max_height
      prev_height = self.height
      self.height = @parent.height if @parent
      debug_log("changed height from #{prev_height} to #{self.height}")
      self
    end

    def set_max_width
      prev_width = self.width
      self.width = @parent.width if @parent
      debug_log("changed width from #{prev_width} to #{self.width}")
      self
    end
  end
end
