# -*- encoding: utf-8 -*-
require File.expand_path('../lib/biscuit-monitor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael D. Hall"]
  gem.email         = ["mdh@just3ws.com"]
  gem.description   = %q{Monitors your CLEAR Spot 4G+ Personal Hotspot.}
  gem.summary       = %q{Console app that will poll your attached Clear Hotspot biscuit.}
  gem.homepage      = "https://github.com/just3ws/biscuit-monitor"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "biscuit-monitor"
  gem.require_paths = ["lib"]
  gem.version       = Biscuit::Monitor::VERSION

  gem.add_runtime_dependency 'colorize'
  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'oj'
  gem.add_runtime_dependency 'sequel'
  gem.add_runtime_dependency 'sqlite3'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'nokogiri-plist'
end
