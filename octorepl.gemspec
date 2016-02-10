# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octorepl/version'

Gem::Specification.new do |spec|
  spec.name          = "octorepl"
  spec.version       = Octorepl::VERSION
  spec.authors       = ["aereal"]
  spec.email         = ["aereal@aereal.org"]

  spec.summary       = %q{REPL for GitHub}
  spec.description   = %q{REPL for GitHub}
  spec.homepage      = "https://github.com/aereal/octorepl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'octokit'
  spec.add_runtime_dependency 'pry'
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
