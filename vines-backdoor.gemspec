# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vines/backdoor/version"

Gem::Specification.new do |spec|
  spec.name          = "vines-backdoor"
  spec.version       = Vines::Backdoor::VERSION
  spec.authors       = ["Strech (Sergey Fedorov)"]
  spec.email         = ["strech_ftf@mail.ru"]
  spec.summary       = "Accelerated http-bind session creation"
  spec.description   = "XMPP protocol extension for Vines server"
  spec.homepage      = "https://github.com/Strech/vines-backdoor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "vines", ">= 0.4.5"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
