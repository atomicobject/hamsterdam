#!/usr/bin/env rake
require "bundler/gem_tasks"
HERE = File.dirname(__FILE__)

Dir[File.expand_path(HERE) + "/rake_tasks/*.rake"].each do |rake_file|
  import rake_file
end

# desc 'Default: run specs and cucumber features'
# task :default => [ "spec", "cuc:features" ]

task :default => [ "spec" ]
