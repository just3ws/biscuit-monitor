# -*- encoding: utf-8 -*-
require File.expand_path('../lib/biscuit-monitor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michael D. Hall"]
  gem.email         = ["mdh@just3ws.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "biscuit-monitor"
  gem.require_paths = ["lib"]
  gem.version       = Biscuit::Monitor::VERSION

  gem.add_runtime_dependency "highline"
end
