# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redmemo/version'

Gem::Specification.new do |spec|
  spec.name          = "redmemo"
  spec.version       = Redmemo::VERSION
  spec.authors       = ["Khaja Minhajuddin"]
  spec.email         = ["minhajuddink@gmail.com"]

  spec.summary       = %q{Redis based memoization}
  spec.description   = %q{Redis based memoization, which should replace your counter caches.}
  spec.homepage      = "http://redmemo.websrvr.in/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
