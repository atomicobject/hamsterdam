# -*- encoding: utf-8 -*-
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/lib")
require "hamsterdam/version"

Gem::Specification.new do |gem|
  gem.authors       = ["David Crosby", "Patrick Bacon"]
  gem.email         = ["david.crosby@atomicobject.com", "bacon@atomicobject.com"]
  gem.description   = %q{Immutable Struct-like record structures based on Hamster.}
  gem.summary       = %q{Immutable Struct-like record structures based on Hamster.}
  gem.homepage      = "https://github.com/atomicobject/hamsterdam"

  gem.files         = ["README.md", "CHANGELOG"] + Dir["lib/**/*.rb"]
  gem.test_files    = Dir["spec/**/*.rb"]
  gem.name          = "hamsterdam"
  gem.require_paths = ["lib"]
  gem.version       = Hamsterdam::VERSION

  gem.add_dependency "hamster", [">= 3.0"]
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "pry"
end
