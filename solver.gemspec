# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solver/version'

Gem::Specification.new do |spec|
  spec.name          = "solver"
  spec.version       = Flt::Solver::VERSION
  spec.authors       = ["Javier Goizueta"]
  spec.email         = ["jgoizueta@gmail.com"]
  spec.summary       = %q{Numeric Solver using Flt}
  spec.description   = %q{This numeric solver is an example of the use of Flt.}
  spec.homepage      = "http://github.com/jgoizueta/solver"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "flt", '~> 1.3.1'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "shoulda-context"
  spec.required_ruby_version = '>= 1.9.2'
end
