# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/asap/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-asap"
  spec.version       = Sidekiq::Asap::VERSION
  spec.authors       = ["Rafal Wojsznis"]
  spec.email         = ["rafal.wojsznis@gmail.com"]
  spec.description   = spec.summary = "Proof of concept"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">= 4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3"
  spec.add_development_dependency "redis-namespace"
end
