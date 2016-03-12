PROJECT_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH << "#{PROJECT_ROOT}/lib"
$LOAD_PATH << "#{PROJECT_ROOT}/spec"

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
Bundler.require(:test)

require 'simplecov' # SimpleCov must come first!
# This start/config code could alternatively go in .simplecov in project root:
SimpleCov.start do 
  add_filter "/spec/"
end

#ENV["APP_ENV"] = "rspec"

require 'pry'
require 'hamsterdam'

if ENV['clj'] == 'true'
  require "#{PROJECT_ROOT}/spec/jars/clojure-1.5.1.jar"
  require 'hamsterdam/clj'
end


# Load all support files
Dir["#{PROJECT_ROOT}/spec/support/*.rb"].each do |support|
  require support
end

RSpec.configure do |config|
  config.include HamsterdamHelpers
end

