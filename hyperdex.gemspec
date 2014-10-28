# coding: utf-8
require 'git-version-bump'

Gem::Specification.new do |spec|
	spec.name          = "hyperdex"
	spec.version       = GVB.version
	spec.date          = GVB.date

	spec.authors       = ["Matt Palmer"]
	spec.email         = ["mpalmer@hezmatt.org"]

	spec.homepage      = "http://theshed.hezmatt.org/hyperdex-ruby"
	spec.summary       = "Hyperdex client bindings"
	spec.license       = "GPLv3"

	spec.files         = `git ls-files -z lib ext`.split("\0")

	spec.extensions = %w{ext/extconf.rb}
	spec.require_paths = %w{ext lib}

	spec.add_runtime_dependency 'ffi-enum-generator'
	spec.add_runtime_dependency 'ffi'
	spec.add_runtime_dependency 'git-version-bump'

	spec.add_development_dependency 'bundler'
	spec.add_development_dependency 'github-release'
	spec.add_development_dependency 'guard-shell'
	spec.add_development_dependency 'guard-spork'
	spec.add_development_dependency 'guard-rspec'
        spec.add_development_dependency 'rb-inotify', '~> 0.9'
        spec.add_development_dependency 'pry-debugger'
	spec.add_development_dependency 'rake'
	spec.add_development_dependency 'yard'
	spec.add_development_dependency 'rspec'
end
