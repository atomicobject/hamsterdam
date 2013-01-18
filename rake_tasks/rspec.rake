begin
require 'rspec/core/rake_task'
rescue Exception => e
  "RSpec is not available.  'spec' task will not be defined."
end

begin # protect from missing rspec
  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    if ENV["file"]
      t.pattern = ENV["file"]
    end
    t.rspec_opts = "--color --format documentation" # --tty
  end
  
  desc "Run individual spec"
  task "spec:just" do
    RSpec::Core::RakeTask.new("_tmp_rspec") do |t|
      t.pattern = ENV["file"] || raise("Please supply 'file' argument")
      t.rspec_opts = "--color"
    end
    Rake::Task["_tmp_rspec"].invoke
  end
rescue Exception => e
end
