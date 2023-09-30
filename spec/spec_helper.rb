# require 'bundler/setup'
# 
# require 'curses'
# 
# require_relative '../lib/text_view'
# 
# RSpec.configure do |config|
#   # Enable flags like --only-failures and --next-failure
#   config.example_status_persistence_file_path = ".rspec_status"
# 
#   config.disable_monkey_patching!
# 
#   config.expect_with :rspec do |c|
#     c.syntax = :expect
#   end
# end
# 

# spec/spec_helper.rb

require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

