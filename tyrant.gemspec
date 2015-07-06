lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tyrant/version'

Gem::Specification.new do |spec|
  spec.name          = "tyrant"
  spec.version       = Tyrant::VERSION
  spec.authors       = ["Nick Sutterer"]
  spec.email         = ["apotonick@gmail.com"]

  spec.summary       = %q{Agnostic authorization for Trailblazer.}
  spec.description   = %q{Agnostic authorization component for Trailblazer.}
  spec.homepage      = "http://github.com/apotonick/tyrant"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"

  spec.add_dependency "trailblazer"
  spec.add_dependency "reform", ">= 2.0.0.rc1"

  spec.add_dependency "bcrypt"
end
