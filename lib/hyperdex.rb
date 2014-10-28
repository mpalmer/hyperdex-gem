require '_hyperdex'

module HyperDex; end

require_relative 'hyperdex/ffi'

require 'ffi'

module HyperDex
	def self.init_ds_iterator(type, value)
		::FFI::MemoryPointer.new(HyperDex::FFI::DS::DsIterator, 1).tap do |iter|
			HyperDex::FFI::DS.iterator_init(iter,
			  type,
			  ::FFI::MemoryPointer.from_string(value),
			  value.length
			)
		end
	end

	DataType = Module.new
	HyperDex::FFI::DS.enum_type(:hyperdatatype).set_consts(DataType)
end

require_relative 'hyperdex/admin'
require_relative 'hyperdex/client'
