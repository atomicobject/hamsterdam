# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hamsterdam', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Crosby"]
  gem.email         = ["david.crosby@atomicobject.com"]
  gem.description   = %q{Immutable Struct-like record structures based on Hamster.}
  gem.summary       = %q{Immutable Struct-like record structures based on Hamster.}
  gem.homepage      = "https://github.com/atomicobject/hamsterdam"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n") - [".gitignore", ".rspec", ".rvmrc", "NOTES.txt", "TODO"]
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "hamsterdam"
  gem.require_paths = ["lib"]
  gem.version       = Hamsterdam::VERSION

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "pry"
end
