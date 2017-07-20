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

  spec.add_development_dependency "activemodel", "~> 4.2.6"

  spec.add_dependency "trailblazer", ">= 2.0.1"
  spec.add_dependency "reform",      ">= 2.3.0.rc1"
  spec.add_dependency "dry-validation"
  spec.add_dependency "disposable",  ">= 0.1.11"

  spec.add_dependency "warden",      ">= 1.2.6"
  spec.add_dependency "bcrypt"


  # spec.add_dependency "pony"
  # spec.add_dependency "formular"

  spec.add_development_dependency "activerecord"

  # spec.add_dependency "trailblazer-cells"
  # spec.add_dependency 'cells-rails'
  # spec.add_dependency 'cells-slim'
end
