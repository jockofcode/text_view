# Require the necessary files
require_relative '../lib/text_view'
# require_relative 'lib/text_view/window'
# require_relative 'lib/text_view/position'
# require_relative 'lib/text_view/draw'

# Initialize the window and include features
TextView::Window.include_feature(TextView::Position) # Assuming Position is a module you want to include
window = TextView::Window.new

# Create child windows
screen = window.create_child
title_bar = window.create_child

# Configure child windows
title_bar.height = 1
title_bar.set_above(screen)
title_bar.set_max_width
screen.set_max_width
screen.set_remaining_height

# Debugging and drawing
screen.debug_log("y: #{screen.pos_y}, x: #{screen.pos_x}, height: #{screen.height}, width: #{screen.width}")
screen.draw { |width, height| TextView::Draw.rectangle(0, 0, width - 1 , height - 1, :white, :black) }
title_bar.draw_char(0, 0, "🍎 File Edit View Window Help", :white, :black)

# Register message types
window.register_message_type(message_type: :quit) do
  window.instance_variable_set(:@quit_flag, true)
  window.debug_log "set @quit_flag to true"
end
screen.register_message_type(message_type: :key_press, args: ['q', 'Q']) { screen.send_quit }

# Run the main loop
window.run
