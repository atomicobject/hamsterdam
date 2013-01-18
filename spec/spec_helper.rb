PROJECT_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH << "#{PROJECT_ROOT}/lib"
$LOAD_PATH << "#{PROJECT_ROOT}/spec"

require 'simplecov' # SimpleCov must come first!
# This start/config code could alternatively go in .simplecov in project root:
SimpleCov.start do 
  add_filter "/spec/"
end

#ENV["APP_ENV"] = "rspec"

require 'hamsterdam'

require 'pry'

# Load all support files
Dir["#{PROJECT_ROOT}/spec/support/*.rb"].each do |support|
  require support
end

RSpec.configure do |config|
  config.include HamsterdamHelpers
end

