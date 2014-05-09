# coding: utf-8
# -*- Ruby -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jewfish/version'

Gem::Specification.new do |spec|
  spec.name          = "jewfish"
  spec.version       = Jewfish::VERSION
  spec.authors       = ["U.Nakamura"]
  spec.email         = ["usa@garbagecollect.jp"]
  spec.summary       = %q{tiny static website generator}
  spec.description   = %q{tiny static website generator}
  spec.homepage      = "https://github.com/unak/jewfish"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "liquid"
  spec.add_runtime_dependency "kramdown"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
