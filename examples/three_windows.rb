# frozen_string_literal: true

# Require the necessary files
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
child.pos_x = 2
child.pos_y = 2

# Create grandchild window
grandchild = child.create_child
grandchild.width = 1
grandchild.height = 1
grandchild.pos_x = 2
grandchild.pos_y = 2

# Register message types for quitting
root.register_message_type(message_type: :quit) do
  root.instance_variable_set(:@quit_flag, true)
  root.debug_log "set @quit_flag to true"
end

# Fill root window with '5'
root.draw do |_width, _height|
  Array.new(5) { |y| Array.new(5) { |x| [y, x, '5', :white, :black] } }
end

# Fill child window with '3'
child.draw do |_width, _height|
  Array.new(3) { |y| Array.new(3) { |x| [y, x, '3', :white, :black] } }
end

# Fill grandchild window with '1'
grandchild.draw do |_width, _height|
  [[0, 0, '1', :white, :black]]
end

# Run the main loop
root.run
