# frozen_string_literal: true

require_relative '../lib/text_view/window'

# Initialize the root window
root = TextView::Window.new
root.width = 5
root.height = 5
root.pos_x = 0
root.pos_y = 0

# Create child window
child = root.create_child
child.width = 3
child.height = 3
child.pos_x = 1
child.pos_y = 1

# Create grandchild window
grandchild = child.create_child
grandchild.width = 1
grandchild.height = 1
grandchild.pos_x = 1
grandchild.pos_y = 1

root.register_message_type(message_type: :quit) do
  root.instance_variable_set(:@quit_flag, true)
  root.debug_log "set @quit_flag to true"
end

# TODO: figure out why quit keypress needs to be set on first level child in order to work. It won't work on root, and it won't work on grandchild
child.register_message_type(message_type: :key_press, args: %w[q Q]) { child.send_quit }

# Fill root window with '5'
root.draw do |width, height|
  instructions = []
  start_x = 0
  start_y = 0
  5.times do |y|
    5.times do |x|
      instructions << [start_y + y, start_x + x, '5', :white, :black]
    end
  end
  instructions
end

# Fill child window with '3'
child.draw do |width, height|
  instructions = []
  start_x = 0
  start_y = 0
  3.times do |y|
    3.times do |x|
      instructions << [start_y + y, start_x + x, '3', :yellow, :black]
    end
  end
  instructions
end

# Fill grandchild window with '1'
grandchild.draw do |_width, _height|
  [[0, 0, '1', :white, :black]]
end

# Run the main loop
root.run
