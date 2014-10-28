# coding: utf-8

Gem::Specification.new do |spec|
	spec.name          = "hyperdex"
	spec.version       = "1.4.4.1"
	spec.authors       = ["Matt Palmer"]
	spec.email         = ["mpalmer@hezmatt.org"]
	spec.summary       = "Hyperdex client bindings"
	spec.description   = <<-EOF.gsub(/^\t\t/, '')
		This gem is packaged from the code in the official HyperDex
		releases, available from http://hyperdex.org/download/.
	EOF
	spec.license       = "GPL"

	spec.files         = %w{
		client.c
		definitions.c
		extconf.rb
		hyperdex.c
		prototypes.c
		visibility.h
	}
	spec.extensions = %w{extconf.rb}
	spec.require_paths = ["."]
end
